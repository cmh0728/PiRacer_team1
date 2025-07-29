
#include <QQuickWindow>
#include <QQmlContext>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtCore/QResource> 

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(qml); 

    QGuiApplication app(argc, argv);

    // Wayland가 아닌 X11 강제
    qputenv("QT_QPA_PLATFORM", "xcb");

    // 전체 화면 설정
    QQuickWindow::setDefaultAlphaBuffer(true);

    // Constants 등록
    qmlRegisterSingletonType(QUrl("qrc:/imports/Cluster/Constants.qml"), "Cluster", 1, 0, "Constants");


    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/content/App.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    
    // 전체화면 + 프레임 제거
    if (!engine.rootObjects().isEmpty()) {
        QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        if (window) {
            window->setFlags(Qt::FramelessWindowHint);
            window->showFullScreen();
        }
    }

    return app.exec();
}
