#ifndef CANRECEIVER_HPP
#define CANRECEIVER_HPP

#include <QObject>
#include <QThread>

class CANReceiver : public QThread {
    Q_OBJECT

public:
    explicit CANReceiver(QObject *parent = nullptr);
    ~CANReceiver();

    // Rule of Three: 복사 방지
    CANReceiver(const CANReceiver&) = delete;
    CANReceiver& operator=(const CANReceiver&) = delete;

    void run() override;

signals:
    void rpmReceived(int rpm);

private:
    int socket_fd;
    bool setupSocket();
    void closeSocket();
};

#endif // CANRECEIVER_HPP
