#include <iostream>
#include <cstring>
#include <unistd.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include "rpm_calculate.h"

CANReceiver::CANReceiver(QObject *parent)
    : QThread(parent), socket_fd(-1) {}

CANReceiver::~CANReceiver() {
    closeSocket();
}

bool CANReceiver::setupSocket() {
    struct ifreq ifr;
    struct sockaddr_can addr;

    socket_fd = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (socket_fd < 0) {
        perror("socket");
        return false;
    }

    std::strcpy(ifr.ifr_name, "can0");
    if (ioctl(socket_fd, SIOCGIFINDEX, &ifr) < 0) {
        perror("SIOCGIFINDEX");
        return false;
    }

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(socket_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
        return false;
    }

    return true;
}

void CANReceiver::closeSocket() {
    if (socket_fd >= 0) {
        close(socket_fd);
        socket_fd = -1;
    }
}

void CANReceiver::run() {
    if (!setupSocket()) {
        return;
    }

    struct can_frame frame;

    while (true) {
        int nbytes = read(socket_fd, &frame, sizeof(struct can_frame));
        if (nbytes < 0) {
            perror("read");
            break;
        }

        if (frame.can_id == 0x100 && frame.can_dlc >= 2) {
            uint16_t raw = (frame.data[0] << 8) | frame.data[1];  // big endian
            emit rpmReceived(static_cast<int>(raw));
        }
    }

    closeSocket();
}
