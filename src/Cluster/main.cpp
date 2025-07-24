#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QStringLiteral>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // (1) importPath를 직접 추가하실 필요가 없습니다.
    //    qt_add_qml_module()가 자동으로 리소스 import 경로를 설정해 줍니다.

    // (2) QML 모듈 URI가 CMakeLists.txt 에서 "URI Cluster" 로 선언되어 있으므로,
    //     최상위 QML 파일은 qrc:/Cluster/Main.qml 에 위치합니다.
    const QUrl url(QStringLiteral("qrc:Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
