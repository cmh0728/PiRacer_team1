// content/Tacho.ui.qml
import QtQuick 6.4

//import MotorClusterData
Item {
    id: root

    property real speed

    width: 300
    height: 300

    Text {
        id: textValue
        text: speed // speedValue는 외부에서 전달
        color: "#ffffff"
        anchors.centerIn: parent
        font.pixelSize: 149
        font.family: "Barlow-mono"
    }

    Text {
        id: unit
        text: "cm/s"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: textValue.bottom
        anchors.topMargin: 0
        color: "#ffffff"
        font.pixelSize: 32
        font.family: "Barlow-mono"
    }
}
