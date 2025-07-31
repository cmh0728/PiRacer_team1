#ifndef CANRECEIVER_HPP
#define CANRECEIVER_HPP

#include <net/if.h>
#include <sys/ioctl.h> 
#include <QObject>
#include <QTimer>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <cstring>  
#include <cstdio> 

// i2c battery 
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>

class CanReceiver : public QObject {
    Q_OBJECT
    Q_PROPERTY(int rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)

    Q_PROPERTY(int batteryPercent  READ batteryPercent NOTIFY batteryChanged) // battery 

    Q_PROPERTY(int gear READ gear NOTIFY gearChanged) // gear status




public:
    explicit CanReceiver(QObject *parent = nullptr);

    int rpm() const { return m_rpm; }
    int speed() const { return m_speed; }
    void setRpm(int value);
    int batteryPercent() const { return m_batteryPercent; }
    int gear() const;

signals:

    void rpmChanged();
    void speedChanged();
    void batteryChanged();
    void gearChanged();

private slots:
    void readCan();
    void readBattery();

private:
    int m_socket;
    int m_rpm = 0;
    int m_speed = 0;
    QTimer *m_timer;

    //for battery 
    qreal m_batteryVoltage    = 0.0;
    int   m_batteryPercent    = 0;
    QTimer* m_battTimer       = nullptr;
    int m_i2c_fd;

    static constexpr qreal MIN_VOLTAGE = 3.0;
    static constexpr qreal MAX_VOLTAGE = 4.2;
    static constexpr qreal WHEEL_DIAM_CM = 6.8;

    // for gear status
    int m_gear = 0;

};

#endif // CANRECEIVER_HPP
