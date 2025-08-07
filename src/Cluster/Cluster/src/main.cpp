#include <QQuickWindow>
#include <QQmlContext>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtCore/QResource> 
#include "CanReceiver.hpp" //can receiver


int main(int argc, char *argv[])
{
    
    // This code is for init qml engine , CanReceiver instance register and for full screen display 
    
    
    Q_INIT_RESOURCE(qml); 

    QGuiApplication app(argc, argv);

    // X11 instead of Wayland
    qputenv("QT_QPA_PLATFORM", "xcb");

    // fullscreen setting
    QQuickWindow::setDefaultAlphaBuffer(true);

    // Constants 
    qmlRegisterSingletonType(QUrl("qrc:/imports/Cluster/Constants.qml"), "Cluster", 1, 0, "Constants");

    // engine
    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/content/App.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    // CAN receiver settting

    CanReceiver receiver;
    engine.rootContext()->setContextProperty("canReceiver", &receiver); 

    engine.load(url); 


    // full screen + delete frame
    if (!engine.rootObjects().isEmpty()) {
        QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        if (window) {
            window->setFlags(Qt::FramelessWindowHint);
            window->showFullScreen();
        }
    }

    return app.exec();
}
