import QtQuick 6.4
import QtQuick.Controls 6.4

Rectangle {
    id: rect; color: "#101010"
    anchors.fill: parent

    // 여기에 Screen02 전용 UI 컴포넌트 배치
    Text {
        anchors.centerIn: parent
        text: "Second UI Screen"
        color: "white"
        font.pixelSize: 40
    }
}
