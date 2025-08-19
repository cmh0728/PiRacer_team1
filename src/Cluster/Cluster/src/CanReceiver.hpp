#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QTimer>

class CanReceiver : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY batteryChanged)
    Q_PROPERTY(int gear READ gear NOTIFY gearChanged)

public:
    explicit CanReceiver(QObject *parent = nullptr);

    // Getter
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
    void readCan();       // CAN 수신 처리
    void readBattery();   // I2C 배터리 읽기 및 CAN 송신

private:
    void setRpm(int value);

    // CAN 소켓
    int m_socket = -1;       // RX용
    int m_txSocket = -1;     // TX용

    QSocketNotifier *m_canNotifier = nullptr;

    // I2C
    int m_i2c_fd = -1;
    QTimer *m_battTimer = nullptr;

    // 상태 값
    int m_rpm = 0;
    int m_speed = 0;
    int m_batteryPercent = 0;
    int m_gear = 0;
};
