#include "CanReceiver.hpp"

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

    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &CanReceiver::readCan);
    m_timer->start(10); // 100 Hz
}

void CanReceiver::readCan() {
    struct can_frame frame {};
    int nbytes = read(m_socket, &frame, sizeof(struct can_frame));

    if (nbytes > 0) {
        if (frame.can_id == 0x100 && frame.can_dlc >= 2) {
            int value = (frame.data[0] << 8) | frame.data[1];
            m_rpm = value; //RPM
            emit rpmChanged();
        }
        
    }
}
