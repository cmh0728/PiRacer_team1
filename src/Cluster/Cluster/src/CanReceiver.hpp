#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QTimer>
#include <QElapsedTimer>   // dt check

class CanReceiver : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY batteryChanged)
    Q_PROPERTY(int gear READ gear NOTIFY gearChanged)

public:
    explicit CanReceiver(QObject *parent = nullptr);
    ~CanReceiver();

    // Getters
    int rpm() const { return m_rpm; }
    int speed() const { return m_speed; }
    int batteryPercent() const { return m_batteryPercent; }
    int gear() const;

signals:
    void rpmChanged();
    void speedChanged();
    void batteryChanged();
    void gearChanged();

private slots:
    void readCan();       // CAN 
    void readBattery();   // I2C battery + CAN commu(0x102)

private:
    void setRpm(int value);

    // CAN socket
    int m_socket   = -1;  // RX
    int m_txSocket = -1;  // TX
    QSocketNotifier *m_canNotifier = nullptr;

    // I2C
    int m_i2c_fd = -1;
    QTimer *m_battTimer = nullptr;

    // 상태 값
    int m_rpm = 0;
    int m_speed = 0;            // cm/s
    int m_batteryPercent = 0;   // %
    int m_gear = 0;

    // =====  =====
    double        m_soc      = 100.0; // [%] 
    QElapsedTimer m_lastUpdate;       // dt 측
    double        m_vFilt    = 0.0;   // fulter
    bool          m_vInit    = false; // init
    double        m_restT    = 0.0;   // [s]
};
