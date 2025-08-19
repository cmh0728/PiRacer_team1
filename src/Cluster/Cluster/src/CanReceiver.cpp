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

// This class reads CAN data (rpm, speed, gear) and also
// reads battery voltage over I2C, converts to % and sends it via CAN (0x102)

CanReceiver::CanReceiver(QObject *parent)
    : QObject(parent)
{
    // 1) CAN 소켓 생성
    m_socket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_socket < 0) {
        perror("Socket");
        return;
    }

    // 2) 논블로킹 모드 설정
    int flags = fcntl(m_socket, F_GETFL, 0);
    if (flags < 0) {
        perror("fcntl F_GETFL");
    } else {
        if (fcntl(m_socket, F_SETFL, flags | O_NONBLOCK) < 0)
            perror("fcntl F_SETFL O_NONBLOCK");
    }

    // 3) 인터페이스 바인딩
    struct ifreq ifr {};
    strncpy(ifr.ifr_name, "can0", IFNAMSIZ - 1);   // ✅ 인터페이스 이름 지정
    ifr.ifr_name[IFNAMSIZ - 1] = '\0';

    if (ioctl(m_socket, SIOCGIFINDEX, &ifr) < 0) {
        perror("SIOCGIFINDEX");
        ::close(m_socket);
        m_socket = -1;
        return;
    }

    struct sockaddr_can addr {};
    addr.can_family  = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (::bind(m_socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind");
        ::close(m_socket);
        m_socket = -1;
        return;
    }

    // 4) QSocketNotifier 생성: 수신 준비되면 readCan() 호출
    m_canNotifier = new QSocketNotifier(m_socket, QSocketNotifier::Read, this);
    connect(m_canNotifier, &QSocketNotifier::activated,
            this, &CanReceiver::readCan);

    // 5) 배터리 I2C 설정
    const char* i2cDev = "/dev/i2c-1";
    m_i2c_fd = ::open(i2cDev, O_RDWR);
    if (m_i2c_fd < 0 || ioctl(m_i2c_fd, I2C_SLAVE, 0x41) < 0) {
        perror("I2C open/addr");
    }

    // 6) 배터리 주기적 읽기 타이머
    m_battTimer = new QTimer(this);
    connect(m_battTimer, &QTimer::timeout, this, &CanReceiver::readBattery);
    m_battTimer->start(3000);  // 3초마다 읽기
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
        constexpr qreal WHEEL_DIAM_CM = 6.8;            // cm
        qreal circumference = M_PI * WHEEL_DIAM_CM;     // cm/rev
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

    // 전압 계산
    uint16_t raw16 = (uint16_t(buf[0]) << 8) | uint16_t(buf[1]);
    int16_t raw12  = raw16 >> 3;
    qreal voltage  = raw12 * 0.004;  // V

    // 퍼센트 변환 (9.0V ~ 12.6V 범위)
    static constexpr qreal MIN_V = 9.0, MAX_V = 12.6;
    qreal pct = (voltage - MIN_V) / (MAX_V - MIN_V) * 100.0;
    int percent = std::lround(qBound<qreal>(0, pct, 100));

    if (percent != m_batteryPercent) {
        m_batteryPercent = percent;
        emit batteryChanged();

        // ===== CAN 송신 (0x102) =====
        if (m_socket >= 0) {
            struct can_frame txFrame {};
            txFrame.can_id  = 0x102;
            txFrame.can_dlc = 1;
            txFrame.data[0] = static_cast<uint8_t>(m_batteryPercent);

            int nbytes = ::write(m_socket, &txFrame, sizeof(txFrame));
            if (nbytes != sizeof(txFrame)) {
                perror("CAN send battery");
            }
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
