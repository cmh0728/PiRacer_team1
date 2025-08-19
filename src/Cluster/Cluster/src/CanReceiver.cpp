#include "CanReceiver.hpp"

#include <QtGlobal>
#include <QDebug>

#include <fcntl.h>
#include <unistd.h>
#include <cerrno>
#include <cmath>
#include <cstring>

#include <sys/ioctl.h>
#include <net/if.h>

#include <linux/can.h>
#include <linux/can/raw.h>
#include <linux/i2c-dev.h>

// 송신/수신 공통: can0 이름을 SIOCGIFINDEX로 변환
static bool bindCanSocketTo(const char* ifname, int sock)
{
    struct ifreq ifr {};
    std::strncpy(ifr.ifr_name, ifname, IFNAMSIZ - 1);
    ifr.ifr_name[IFNAMSIZ - 1] = '\0';

    if (ioctl(sock, SIOCGIFINDEX, &ifr) < 0) {
        perror("SIOCGIFINDEX");
        return false;
    }

    struct sockaddr_can addr {};
    addr.can_family  = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (::bind(sock, reinterpret_cast<struct sockaddr*>(&addr), sizeof(addr)) < 0) {
        perror("bind");
        return false;
    }
    return true;
}

CanReceiver::CanReceiver(QObject *parent)
    : QObject(parent)
{
    // ===== 1) CAN 수신 소켓 =====
    m_socket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_socket < 0) {
        perror("Socket RX");
        return;
    }

    // 논블로킹
    int flags = fcntl(m_socket, F_GETFL, 0);
    if (flags >= 0) {
        if (fcntl(m_socket, F_SETFL, flags | O_NONBLOCK) < 0)
            perror("fcntl RX O_NONBLOCK");
    }

    // 자신이 보낸 프레임도 수신 소켓에서 받도록(디바이스 loopback이 꺼져있어도 방지용)
    {
        int recv_own = 1;
        if (setsockopt(m_socket, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS, &recv_own, sizeof(recv_own)) < 0) {
            perror("setsockopt CAN_RAW_RECV_OWN_MSGS (RX)");
        }
    }

    if (!bindCanSocketTo("can0", m_socket)) {
        ::close(m_socket);
        m_socket = -1;
        return;
    }

    // 수신 이벤트 처리
    m_canNotifier = new QSocketNotifier(m_socket, QSocketNotifier::Read, this);
    connect(m_canNotifier, &QSocketNotifier::activated,
            this, &CanReceiver::readCan);

    // ===== 2) CAN 송신 소켓 =====
    m_txSocket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_txSocket < 0) {
        perror("Socket TX");
    } else {
        // 송신 소켓도 같은 인터페이스로 바인딩
        if (!bindCanSocketTo("can0", m_txSocket)) {
            ::close(m_txSocket);
            m_txSocket = -1;
        } else {
            // (옵션) 송신 소켓도 자기 프레임 에코 받기 원하면 켜둠
            int recv_own = 1;
            if (setsockopt(m_txSocket, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS, &recv_own, sizeof(recv_own)) < 0) {
                perror("setsockopt CAN_RAW_RECV_OWN_MSGS (TX)");
            }
        }
    }

    // ===== 3) 배터리 I2C 설정 =====
    const char* i2cDev = "/dev/i2c-1";
    m_i2c_fd = ::open(i2cDev, O_RDWR);
    if (m_i2c_fd < 0) {
        perror("I2C open");
    } else if (ioctl(m_i2c_fd, I2C_SLAVE, 0x41) < 0) {
        perror("I2C set slave");
        ::close(m_i2c_fd);
        m_i2c_fd = -1;
    }

    // ===== 4) 배터리 주기적 읽기 =====
    m_battTimer = new QTimer(this);
    connect(m_battTimer, &QTimer::timeout, this, &CanReceiver::readBattery);
    m_battTimer->start(3000);  // 3초마다
}

CanReceiver::~CanReceiver()
{
    if (m_canNotifier) {
        m_canNotifier->setEnabled(false);
        m_canNotifier->deleteLater();
        m_canNotifier = nullptr;
    }
    if (m_socket >= 0) {
        ::close(m_socket);
        m_socket = -1;
    }
    if (m_txSocket >= 0) {
        ::close(m_txSocket);
        m_txSocket = -1;
    }
    if (m_i2c_fd >= 0) {
        ::close(m_i2c_fd);
        m_i2c_fd = -1;
    }
}

void CanReceiver::readCan()
{
    struct can_frame frame {};
    int nbytes = ::read(m_socket, &frame, sizeof(frame));
    if (nbytes < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK)
            return;
        perror("CAN read");
        return;
    }

    // RPM (0x100)
    if ((frame.can_id & CAN_EFF_FLAG) == 0 && frame.can_id == 0x100 && frame.can_dlc >= 2) {
        int rpmValue = (frame.data[0] << 8) | frame.data[1];
        setRpm(rpmValue);

        // cm/s 계산 (바퀴 지름 6.8 cm)
        constexpr qreal WHEEL_DIAM_CM = 6.8;
        qreal circumference = M_PI * WHEEL_DIAM_CM;   // cm/rev
        qreal rev_per_sec   = rpmValue / 60.0;
        int cms = qRound(rev_per_sec * circumference);

        if (cms != m_speed) {
            m_speed = cms;
            emit speedChanged();
        }
        // qDebug() << "[CAN RX] 0x100 RPM=" << rpmValue << "Speed=" << m_speed << "cm/s";
    }
    // 기어 (0x101)
    else if ((frame.can_id & CAN_EFF_FLAG) == 0 && frame.can_id == 0x101 && frame.can_dlc >= 1) {
        int newGear = frame.data[0];
        if (newGear != m_gear) {
            m_gear = newGear;
            emit gearChanged();
        }
        // qDebug() << "[CAN RX] 0x101 Gear=" << m_gear;
    }
    // 배터리 에코 확인용 (0x102)
    else if ((frame.can_id & CAN_EFF_FLAG) == 0 && frame.can_id == 0x102 && frame.can_dlc >= 1) {
        // 로컬 echo가 켜져있으면 여기로도 들어옴
        // qDebug() << "[CAN RX] 0x102 Battery Echo=" << int(frame.data[0]) << "%";
    }
}

void CanReceiver::readBattery()
{
    if (m_i2c_fd < 0) return;

    // INA219 Bus Voltage Register (0x02) 읽기
    uint8_t reg = 0x02;
    if (::write(m_i2c_fd, &reg, 1) != 1) return;

    uint8_t buf[2] = {0};
    if (::read(m_i2c_fd, buf, 2) != 2) return;

    // 12-bit 값으로 전압 환산
    uint16_t raw16 = (uint16_t(buf[0]) << 8) | uint16_t(buf[1]);
    int16_t raw12  = raw16 >> 3;
    qreal voltage  = raw12 * 0.004;  // V

    // 9.0V ~ 12.6V → 0~100%
    static constexpr qreal MIN_V = 9.0, MAX_V = 12.6;
    qreal pct = (voltage - MIN_V) / (MAX_V - MIN_V) * 100.0;
    int newPercent = std::lround(qBound<qreal>(0, pct, 100));

    bool changed = (newPercent != m_batteryPercent);
    m_batteryPercent = newPercent;
    if (changed) emit batteryChanged();

    // ⚠ 항상 주기 송신 (변화 없어도 candump/server에서 보이도록)
    if (m_txSocket >= 0) {
        struct can_frame tx {};
        tx.can_id  = 0x102;     // 표준 11-bit ID
        tx.can_dlc = 1;
        tx.data[0] = static_cast<uint8_t>(m_batteryPercent);

        int written = ::write(m_txSocket, &tx, sizeof(tx));
        if (written != sizeof(tx)) {
            perror("CAN send battery (0x102)");
        } else {
            // 디버그 로그
            // qDebug() << "[BAT TX]" << m_batteryPercent << "% (V=" << voltage << ")";
        }
    } else {
        qWarning() << "[BAT TX] m_txSocket invalid. Battery=" << m_batteryPercent << "%";
    }
}

void CanReceiver::setRpm(int value)
{
    if (m_rpm != value) {
        m_rpm = value;
        emit rpmChanged();
    }
}

int CanReceiver::gear() const
{
    return m_gear;
}
