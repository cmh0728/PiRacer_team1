#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtCore/QResource> 

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(qml); 

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/content/App.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
