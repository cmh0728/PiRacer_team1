#include "CanReceiver.hpp"
#include <fcntl.h>
#include <unistd.h>
#include <cmath>
#include <QDebug>   


CanReceiver::CanReceiver(QObject *parent) : QObject(parent) {
    struct ifreq ifr {};
    struct sockaddr_can addr {};

    m_socket = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_socket < 0) {
        perror("Socket");
        return;
    }

    strcpy(ifr.ifr_name, "can0");
    ioctl(m_socket, SIOCGIFINDEX, &ifr);

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    bind(m_socket, (struct sockaddr *)&addr, sizeof(addr));

    //battery socket
    const char* i2cDev = "/dev/i2c-1";
    m_i2c_fd = ::open(i2cDev, O_RDWR);
    if (m_i2c_fd < 0 || ioctl(m_i2c_fd, I2C_SLAVE, 0x41) < 0) {
        perror("I2C open/addr");
    }

    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &CanReceiver::readCan);
    m_timer->start(10); // 100 Hz

    // timer for battery. per 3s
    m_battTimer = new QTimer(this);
    connect(m_battTimer, &QTimer::timeout, this, &CanReceiver::readBattery);
    m_battTimer->start(3000); //3000ms
}

void CanReceiver::readCan() {
    struct can_frame frame {};
    int nbytes = read(m_socket, &frame, sizeof(struct can_frame));

    if (nbytes > 0) {
        if (frame.can_id == 0x100 && frame.can_dlc >= 2) {
            int value = (frame.data[0] << 8) | frame.data[1];
            // m_rpm = value; //RPM
            // emit rpmChanged();
            setRpm(value);

            //speed
            qreal circumference = M_PI * WHEEL_DIAM_CM;        // cm
            qreal cm_per_min   = value * circumference;        // cm/min
            qreal cm_per_sec   = cm_per_min / 60.0;            // cm/s
            int   speed_cm_s   = int(std::lround(cm_per_sec)); // 정수로 반올림

            if (speed_cm_s != m_speed) {
                m_speed = speed_cm_s;
                emit speedChanged();
            }
        }
        else if (frame.can_id == 0x101 && frame.can_dlc >= 1) {
            int newGear = frame.data[0];
            if (newGear != m_gear) {
                m_gear = newGear;
                emit gearChanged();
            }
        }

    }

}

void CanReceiver::readBattery() // I2C read  0x41
{
    uint8_t reg = 0x02;
    if (::write(m_i2c_fd, &reg, 1) != 1) return;

    uint8_t buf[2] = {0};
    if (::read(m_i2c_fd, buf, 2) != 2) return;

    // 1) MSB(상위바이트)=buf[0], LSB=buf[1]
    uint16_t raw16 = (uint16_t(buf[0]) << 8) | uint16_t(buf[1]);

    // 2) 상위 12비트 추출 (LSB 3비트는 비어있음)
    int16_t raw12  = raw16 >> 3;

    // 3) 전압 계산 (LSB = 4 mV)
    qreal voltage = raw12 * 0.004;  // V

    // 4) 디버그 (필요시 활성화)
    qDebug()
        << "[INA219]"
        << ("raw16=0x" + QString::number(raw16, 16).toUpper())
        << QString("voltage=%1V").arg(voltage);

    // 5) 3셀 범위(9.0–12.6 V) → 0–100%
    static constexpr qreal MIN_V = 9.0, MAX_V = 12.6;
    qreal pct = (voltage - MIN_V)/(MAX_V - MIN_V)*100.0;
    int percent = std::lround(qBound<qreal>(0, pct, 100));

    if (percent != m_batteryPercent) {
        m_batteryPercent = percent;
        emit batteryChanged();
    }
}


void CanReceiver::setRpm(int value) {
    if (m_rpm != value) {
        m_rpm = value;
        emit rpmChanged();
    }
}

int CanReceiver::gear() const { return m_gear; }