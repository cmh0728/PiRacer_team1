// 이 부분은 그대로 두세요
import QtQuick
import QtQuickUltralite.Extras
import MotorClusterData

Item {
    id: root

    property real speed

    width: 300
    height: 300

    Text {
        text: speed // 이제 이 speedValue는 외부에서 받은 값을 참조합니다.
        id: textValue
        color: Style.white
        anchors.centerIn: parent
        font.pixelSize: 149
        font.family: "Barlow-mono"
    }

    StaticText {
        id: unit
        font.pixelSize: 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 0
        anchors.topMargin: 0
        font.family: "Barlow-mono"
        color: Style.white
        text: "cm/s"
        anchors.top: textValue.bottom
    }
}
