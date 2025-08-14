// content/RpmSegment.ui.qml
import QtQuick 6.4

Item {
    id: root
    // ColorizedImage와 호환되는 속성들 (ui.qml에서는 color 틴트는 미사용)
    property url   source: "../images/big/tacho/6.png"
    property color color: "#ffffff"
    property bool  mirror: false
    property real  scale: 1.0
    property int   fillMode: Image.PreserveAspectFit

    // 외부에서 width/height 미지정 시 이미지의 암시 크기에 scale 반영
    implicitWidth:  img.implicitWidth  * (scale < 0 ? -scale : scale)
    implicitHeight: img.implicitHeight * (scale < 0 ? -scale : scale)

    Image {
        id: img
        anchors.centerIn: parent
        source: root.source
        fillMode: root.fillMode
        sourceSize.width:  width
        sourceSize.height: height
        smooth: true

        // 좌우 반전 + 스케일
        transform: Scale {
            origin.x: img.width / 2
            origin.y: img.height / 2
            xScale: root.mirror ? -root.scale : root.scale
            yScale: root.scale
        }
    }
}
