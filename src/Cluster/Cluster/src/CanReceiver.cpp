#include "CanReceiver.hpp"
#include <fcntl.h>
#include <unistd.h>
#include <cmath>

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
        }
        
    }
}

void CanReceiver::readBattery()
{
    // 버스 전압 레지스터(0x02) 읽기
    uint8_t reg = 0x02;
    if (::write(m_i2c_fd, &reg, 1) != 1) return;

    uint8_t buf[2] = {0};
    if (::read(m_i2c_fd, buf, 2) != 2) return;

    int16_t raw = (buf[0] << 8) | buf[1];
    // 상위 12비트 ▶ 전압(LSB=4mV)
    qreal voltage = (raw >> 3) * 0.004;

    // 3.0-4.2V → 0-100%
    qreal pct = (voltage - MIN_VOLTAGE) / (MAX_VOLTAGE - MIN_VOLTAGE) * 100.0;
    int   percent = std::lround(qBound<qreal>(0.0, pct, 100.0));

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
