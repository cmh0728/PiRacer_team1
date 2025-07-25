import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    color: "darkblue"
    title: qsTr("QML 테스트")

    Text {
        text: "QML 로드 성공 🎉"
        anchors.centerIn: parent
        font.pixelSize: 24
        color: "white"
    }
}
