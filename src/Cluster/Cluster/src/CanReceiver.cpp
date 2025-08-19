#include "CanReceiver.hpp"
#include <fcntl.h>
#include <unistd.h>
#include <cerrno>
#include <cmath>
#include <cstring>
#include <QDebug>
#include <errno.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <linux/i2c-dev.h>

// This class reads CAN data (rpm, speed, gear) and also
// reads battery voltage over I2C, converts to % and sends it via CAN (0x102)

CanReceiver::CanReceiver(QObject *parent)
    : QObject(parent)
{
    // 1) CAN 수신 소켓 생성
    m_socket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_socket < 0) {
        perror("Socket RX");
        return;
    }

    // 논블로킹 모드
    int flags = fcntl(m_socket, F_GETFL, 0);
    if (flags >= 0) {
        if (fcntl(m_socket, F_SETFL, flags | O_NONBLOCK) < 0)
            perror("fcntl RX O_NONBLOCK");
    }

    // 인터페이스 바인딩 (수신용)
    struct ifreq ifr {};
    strncpy(ifr.ifr_name, "can0", IFNAMSIZ - 1);
    ifr.ifr_name[IFNAMSIZ - 1] = '\0';

    if (ioctl(m_socket, SIOCGIFINDEX, &ifr) < 0) {
        perror("SIOCGIFINDEX RX");
        ::close(m_socket);
        m_socket = -1;
        return;
    }

    struct sockaddr_can addr {};
    addr.can_family  = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (::bind(m_socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind RX");
        ::close(m_socket);
        m_socket = -1;
        return;
    }

    // QSocketNotifier → 수신 이벤트 처리
    m_canNotifier = new QSocketNotifier(m_socket, QSocketNotifier::Read, this);
    connect(m_canNotifier, &QSocketNotifier::activated,
            this, &CanReceiver::readCan);

    // 2) CAN 송신 소켓 생성
    m_txSocket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_txSocket < 0) {
        perror("Socket TX");
    } else {
        struct ifreq ifr_tx {};
        strncpy(ifr_tx.ifr_name, "can0", IFNAMSIZ - 1);
        ifr_tx.ifr_name[IFNAMSIZ - 1] = '\0';

        if (ioctl(m_txSocket, SIOCGIFINDEX, &ifr_tx) < 0) {
            perror("SIOCGIFINDEX TX");
            ::close(m_txSocket);
            m_txSocket = -1;
        } else {
            struct sockaddr_can addr_tx {};
            addr_tx.can_family  = AF_CAN;
            addr_tx.can_ifindex = ifr_tx.ifr_ifindex;
            if (::bind(m_txSocket, (struct sockaddr*)&addr_tx, sizeof(addr_tx)) < 0) {
                perror("bind TX");
                ::close(m_txSocket);
                m_txSocket = -1;
            }
        }
    }

    // 3) 배터리 I2C 설정
    const char* i2cDev = "/dev/i2c-1";
    m_i2c_fd = ::open(i2cDev, O_RDWR);
    if (m_i2c_fd < 0 || ioctl(m_i2c_fd, I2C_SLAVE, 0x41) < 0) {
        perror("I2C open/addr");
    }

    // 4) 배터리 주기적 읽기 타이머
    m_battTimer = new QTimer(this);
    connect(m_battTimer, &QTimer::timeout, this, &CanReceiver::readBattery);
    m_battTimer->start(3000);  // 3초마다
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

    // RPM 데이터 (0x100)
    if (frame.can_id == 0x100 && frame.can_dlc >= 2) {
        int rpmValue = (frame.data[0] << 8) | frame.data[1];
        setRpm(rpmValue);

        // 속도 계산 (cm/s)
        constexpr qreal WHEEL_DIAM_CM = 6.8;           // cm
        qreal circumference = M_PI * WHEEL_DIAM_CM;    // cm/rev
        qreal rev_per_sec = rpmValue / 60.0;
        int cms = qRound(rev_per_sec * circumference);

        if (cms != m_speed) {
            m_speed = cms;
            emit speedChanged();
        }
    }

    // 기어 데이터 (0x101)
    else if (frame.can_id == 0x101 && frame.can_dlc >= 1) {
        int newGear = frame.data[0];
        if (newGear != m_gear) {
            m_gear = newGear;
            emit gearChanged();
        }
    }
}

void CanReceiver::readBattery()
{
    if (m_i2c_fd < 0) return;

    uint8_t reg = 0x02;
    if (::write(m_i2c_fd, &reg, 1) != 1) return;

    uint8_t buf[2] = {0};
    if (::read(m_i2c_fd, buf, 2) != 2) return;

    uint16_t raw16 = (uint16_t(buf[0]) << 8) | uint16_t(buf[1]);
    int16_t raw12  = raw16 >> 3;
    qreal voltage  = raw12 * 0.004;  // V

    static constexpr qreal MIN_V = 9.0, MAX_V = 12.6;
    qreal pct = (voltage - MIN_V) / (MAX_V - MIN_V) * 100.0;
    int newPercent = std::lround(qBound<qreal>(0, pct, 100));

    bool changed = (newPercent != m_batteryPercent);
    m_batteryPercent = newPercent;
    if (changed) emit batteryChanged();

    // 🔁 항상 송신 (주기 3초)
    if (m_txSocket >= 0) {
        struct can_frame txFrame {};
        txFrame.can_id  = 0x102;
        txFrame.can_dlc = 1;
        txFrame.data[0] = static_cast<uint8_t>(m_batteryPercent);

        int nbytes = ::write(m_txSocket, &txFrame, sizeof(txFrame));
        if (nbytes != sizeof(txFrame)) {
            perror("CAN send battery");
        }
    }
}


void CanReceiver::setRpm(int value) {
    if (m_rpm != value) {
        m_rpm = value;
        emit rpmChanged();
    }
}

int CanReceiver::gear() const { return m_gear; }
