import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    width: 400; height: 300
    color: "darkblue"

    Text {
        text: "QML 로드 성공 🎉"
        anchors.centerIn: parent
        font.pixelSize: 24
        color: "white"
    }

    // 예: SpeedGauge, RpmGauge 같은 커스텀 컴포넌트를 qml/Gauge.qml 등에 정의
    // SpeedGauge {
    //     id: speedo
    //     anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
    //     x: 50
    //     width: 400; height: 400
    //     unit: "cm/s"
    //     value: 90
    // }

    // RpmGauge {
    //     id: tach
    //     anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
    //     x: -50
    //     width: 400; height: 400
    //     unit: "×1000rpm"
    //     value: 3
    // }

    // Image {
    //     source: "qrc:/images/car_center.png"
    //     anchors.centerIn: parent
    // }

    // BatteryIndicator {
    //     id: batt
    //     anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
    //     width: 400; height: 40
    //     level: 0.7  // 0.0 ~ 1.0
    // }
}
