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

'''
This code for read CAN data and register Q_PROPERTY
rpm, speed, battery status , gear status
'''

CanReceiver::CanReceiver(QObject *parent)
    : QObject(parent)
{
    // make CAN socket
    m_socket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_socket < 0) {
        perror("Socket");
        return;
    }

    // setting non-blocket mode(socket)
    int flags = fcntl(m_socket, F_GETFL, 0);
    if (flags < 0) {
        perror("fcntl F_GETFL");
    } else {
        if (fcntl(m_socket, F_SETFL, flags | O_NONBLOCK) < 0) //non blocking setting
            perror("fcntl F_SETFL O_NONBLOCK");
    }

    // interface binding
    struct ifreq ifr {};
    ioctl(m_socket, SIOCGIFINDEX, &ifr);
    struct sockaddr_can addr {};
    addr.can_family  = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (::bind(m_socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind");
        ::close(m_socket);
        m_socket = -1;
        return;
    }

    // make QSocketNotifier--> call readCan() 
    m_canNotifier = new QSocketNotifier(m_socket, QSocketNotifier::Read, this);
    connect(m_canNotifier, &QSocketNotifier::activated,
            this, &CanReceiver::readCan);

    // battery setting (I2C)
    const char* i2cDev = "/dev/i2c-1";
    m_i2c_fd = ::open(i2cDev, O_RDWR);
    if (m_i2c_fd < 0 || ioctl(m_i2c_fd, I2C_SLAVE, 0x41) < 0) {
        perror("I2C open/addr");
    }

    m_battTimer = new QTimer(this);
    connect(m_battTimer, &QTimer::timeout, this, &CanReceiver::readBattery);
    m_battTimer->start(3000);
}

void CanReceiver::readCan()
{
    struct can_frame frame {};
    int nbytes = ::read(m_socket, &frame, sizeof(frame));
    if (nbytes < 0) {
        // return if data is none
        if (errno == EAGAIN || errno == EWOULDBLOCK)
            return;
        perror("CAN read");
        return;
    }

    // read
    if (frame.can_id == 0x100 && frame.can_dlc >= 2) {
        int rpmValue = (frame.data[0] << 8) | frame.data[1];
        setRpm(rpmValue);

        // --- cm/s 계산 ---
        constexpr qreal WHEEL_DIAM_M = 6.8 ;  // 6.8 cm 
        qreal circumference = M_PI * WHEEL_DIAM_M;   // 둘레 

        // rpmValue 회전 → 초당 회전수 = rpmValue / 60
        qreal revolutions_per_sec = rpmValue / 60.0;

        // 초당 이동 거리(m) = revolutions_per_sec * circumference
        qreal cmmeters_per_sec = revolutions_per_sec * circumference;
        int cms = qRound(cmmeters_per_sec);

        if (cms != m_speed) {
            m_speed = cms;
            // qDebug() << "[CanReceiver] new speed(cm/s):" << m_speed;
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

void CanReceiver::readBattery() // I2C read  0x41
{
    uint8_t reg = 0x02;
    if (::write(m_i2c_fd, &reg, 1) != 1) return;

    uint8_t buf[2] = {0};
    if (::read(m_i2c_fd, buf, 2) != 2) return;

    // MSB
    uint16_t raw16 = (uint16_t(buf[0]) << 8) | uint16_t(buf[1]);

    // LSB
    int16_t raw12  = raw16 >> 3;

    // calculate vlotage
    qreal voltage = raw12 * 0.004;  // V

    // for debugging battery status
    // debugging --> 12.2v check . 
    // qDebug()
    //     << "[INA219]"
    //     << ("raw16=0x" + QString::number(raw16, 16).toUpper())
    //     << QString("voltage=%1V").arg(voltage);

    // voltage to percent(linear interpolation)
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