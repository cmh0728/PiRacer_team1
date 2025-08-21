// MusicToggleButton.ui.qml
import QtQuick 6.4
import QtQuick.Controls 6.4

Item {
    id: root
    // 외부에서 읽는 상태: true면 켜짐(플레이어 표시 등)
    property bool toggled: false

    // 커스터마이즈 가능한 프로퍼티
    property int size: 36
    property real scaleFactor: 1.5
    property string iconText: "♫"
    property color bgColor: Qt.rgba(0, 0, 0, 0.35)
    property color borderColor: Qt.rgba(255, 255, 255, 0.15)
    property color iconOn: "#ffffff"
    property color iconOff: "#d0d0d0"

    width: size * scaleFactor
    height: size * scaleFactor

    // 원형 버튼
    Rectangle {
        id: button
        anchors.fill: parent
        radius: width / 2
        color: bgColor
        border.color: borderColor
        border.width: 1
        clip: true

        Text {
            anchors.centerIn: parent
            text: iconText
            color: root.toggled ? iconOn : iconOff
            // 원본 예제의 스케일 반영
            font.pixelSize: Math.max(14, root.size / 2)
            scale: 1.5
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // ★ .ui.qml 규칙: 단일 대입식으로 토글
            onClicked: root.toggled = !root.toggled
        }
    }
}
