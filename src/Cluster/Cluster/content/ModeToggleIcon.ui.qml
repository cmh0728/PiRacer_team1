// ModeToggleIcon.ui.qml  (Screen01/Screen02와 같은 폴더에 두는 것을 권장)
import QtQuick 6.4
import QtQuick.Controls 6.4

Item {
    id: root
    // 외부에서 감지할 토글 상태
    property bool trigger: false
    // 외부에서 아이콘 경로/크기 조절
    property alias source: icon.source
    property int iconSize: 32

    width: iconSize
    height: iconSize
    z: 9999

    Image {
        id: icon
        anchors.fill: parent
        source: "../images/sport.png" // 기본값. 프로젝트에 맞게 변경 가능
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // ★ 함수 호출 없이 단일 대입식
        onClicked: root.trigger = !root.trigger
    }
}
