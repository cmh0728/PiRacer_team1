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

class CanReceiver : public QObject {
    Q_OBJECT
    Q_PROPERTY(int rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)


public:
    explicit CanReceiver(QObject *parent = nullptr);

    int rpm() const { return m_rpm; }
    int speed() const { return m_speed; }
    void setRpm(int value);
    
signals:

    void rpmChanged();
    void speedChanged();

private slots:
    void readCan();

private:
    int m_socket;
    int m_rpm = 0;
    int m_speed = 0;
    QTimer *m_timer;
};
