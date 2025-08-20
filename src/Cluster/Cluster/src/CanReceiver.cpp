#include "CanReceiver.hpp"

#include <QtGlobal>
#include <QDebug>

#include <fcntl.h>
#include <unistd.h>
#include <cerrno>
#include <cmath>
#include <cstring>
#include <algorithm>  // std::clamp

#include <sys/ioctl.h>
#include <net/if.h>

#include <linux/can.h>
#include <linux/can/raw.h>
#include <linux/i2c-dev.h>

// Bind CAN socket to interface
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
    // CAN RX socket
    m_socket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_socket < 0) {
        perror("Socket RX");
        return;
    }

    int flags = fcntl(m_socket, F_GETFL, 0);
    if (flags >= 0) {
        if (fcntl(m_socket, F_SETFL, flags | O_NONBLOCK) < 0)
            perror("fcntl RX O_NONBLOCK");
    }

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

    m_canNotifier = new QSocketNotifier(m_socket, QSocketNotifier::Read, this);
    connect(m_canNotifier, &QSocketNotifier::activated,
            this, &CanReceiver::readCan);

    // CAN TX socket
    m_txSocket = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_txSocket < 0) {
        perror("Socket TX");
    } else {
        if (!bindCanSocketTo("can0", m_txSocket)) {
            ::close(m_txSocket);
            m_txSocket = -1;
        } else {
            int recv_own = 1;
            if (setsockopt(m_txSocket, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS, &recv_own, sizeof(recv_own)) < 0) {
                perror("setsockopt CAN_RAW_RECV_OWN_MSGS (TX)");
            }
        }
    }

    // I2C init
    const char* i2cDev = "/dev/i2c-1";
    m_i2c_fd = ::open(i2cDev, O_RDWR);
    if (m_i2c_fd < 0) {
        perror("I2C open");
    } else if (ioctl(m_i2c_fd, I2C_SLAVE, 0x41) < 0) {
        perror("I2C set slave");
        ::close(m_i2c_fd);
        m_i2c_fd = -1;
    }

    // Battery periodic read
    m_battTimer = new QTimer(this);
    connect(m_battTimer, &QTimer::timeout, this, &CanReceiver::readBattery);
    m_battTimer->start(3000);

    m_lastUpdate.start();
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

        constexpr qreal WHEEL_DIAM_CM = 6.8;
        qreal circumference = M_PI * WHEEL_DIAM_CM;   
        qreal rev_per_sec   = rpmValue / 60.0;
        int cms = qRound(rev_per_sec * circumference);

        if (cms != m_speed) {
            m_speed = cms;
            emit speedChanged();
        }
    }
    // Gear (0x101)
    else if ((frame.can_id & CAN_EFF_FLAG) == 0 && frame.can_id == 0x101 && frame.can_dlc >= 1) {
        int newGear = frame.data[0];
        if (newGear != m_gear) {
            m_gear = newGear;
            emit gearChanged();
        }
    }
    // Battery echo (0x102)
    else if ((frame.can_id & CAN_EFF_FLAG) == 0 && frame.can_id == 0x102 && frame.can_dlc >= 1) {
        // local echo
    }
}

void CanReceiver::readBattery()
{
    if (m_i2c_fd < 0) return;

    // Bus Voltage (0x02, LSB=4mV)
    uint8_t reg = 0x02;
    if (::write(m_i2c_fd, &reg, 1) != 1) return;
    uint8_t buf[2] = {0};
    if (::read(m_i2c_fd, buf, 2) != 2) return;

    uint16_t raw16 = (uint16_t(buf[0]) << 8) | uint16_t(buf[1]);
    int16_t  raw12 = raw16 >> 3;            
    double   v_pack = raw12 * 0.004;        

    // Shunt Voltage (0x01, LSB=10µV)
    reg = 0x01;
    if (::write(m_i2c_fd, &reg, 1) != 1) return;
    if (::read(m_i2c_fd, &buf[0], 2) != 2) return;
    int16_t rawShunt = (int16_t(buf[0] << 8) | buf[1]);
    double  v_shunt  = rawShunt * 10e-6;    
    double  i_amps   = v_shunt / 0.1;       
    double  i_mA     = i_amps * 1000.0;     

    double dt = m_lastUpdate.isValid() ? (m_lastUpdate.restart() / 1000.0) : 0.0;
    if (dt <= 0.0) { dt = 0.001; m_lastUpdate.start(); }

    if (!m_vInit) { m_vFilt = v_pack; m_vInit = true; }
    else          { m_vFilt = 0.9 * m_vFilt + 0.1 * v_pack; }

    static double prevV = m_vFilt;
    double dv = std::fabs(m_vFilt - prevV);
    prevV = m_vFilt;

    bool isRestLike = (std::fabs(i_mA) < 100.0) && ((dv / dt) < 0.005);
    m_restT = isRestLike ? (m_restT + dt) : 0.0;

    static constexpr double CAPACITY_mAh = 3200.0;
    double delta_mAh = (i_mA * dt) / 3600.0;
    double deltaSOC  = (delta_mAh / CAPACITY_mAh) * 100.0;
    m_soc -= deltaSOC;                              
    if (m_soc < 0.0)   m_soc = 0.0;
    if (m_soc > 100.0) m_soc = 100.0;

    // cutoff voltage
    if (m_vFilt <= 10.0) {
        m_soc = 0.0;
    }

    // OCV correction
    static const std::vector<std::pair<double,int>> OCV_LUT = {
    {4.20, 100}, {4.10, 90}, {3.95, 80}, {3.87, 70},
    {3.83, 60},  {3.80, 50}, {3.75, 40}, {3.70, 30},
    {3.65, 20},  {3.50, 10}, {3.33, 0}
    };

    auto ocvToSoc = [&](double v_cell)->int {
        if (v_cell >= OCV_LUT.front().first) return OCV_LUT.front().second;
        if (v_cell <= OCV_LUT.back().first)  return OCV_LUT.back().second;
        for (size_t i = 1; i < OCV_LUT.size(); ++i) {
            if (v_cell > OCV_LUT[i].first) {
                double v1 = OCV_LUT[i-1].first, v2 = OCV_LUT[i].first;
                int    s1 = OCV_LUT[i-1].second, s2 = OCV_LUT[i].second;
                double t  = (v_cell - v2) / (v1 - v2);
                return static_cast<int>(std::lround(s2 + t*(s1 - s2)));
            }
        }
        return 0;
    };
    if (m_restT > 10.0) {
        int ocvSoc = ocvToSoc(m_vFilt / 3.0);   
        m_soc = 0.9 * m_soc + 0.1 * ocvSoc;     
    }

    int newPercent = static_cast<int>(std::lround(std::clamp(m_soc, 0.0, 100.0)));
    if (std::abs(newPercent - m_batteryPercent) >= 1) {
        m_batteryPercent = newPercent;
        emit batteryChanged();
    }

    if (m_txSocket >= 0) {
        struct can_frame tx {};
        tx.can_id  = 0x102;     
        tx.can_dlc = 1;
        tx.data[0] = static_cast<uint8_t>(m_batteryPercent);

        int written = ::write(m_txSocket, &tx, sizeof(tx));
        if (written != sizeof(tx)) {
            perror("CAN send battery (0x102)");
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
