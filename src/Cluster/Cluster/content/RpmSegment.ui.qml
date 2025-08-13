// content/RpmSegment.ui.qml
import QtQuick 6.4

Item {
    id: root
    property url   source: "../images/big/tacho/6.png"   // ? ??? ?? (?? ?? ??)
    property color color: "#ffffff"                      // (??) .ui.qml??? ?? ??? ? ?? ???
    property bool  mirror: false
    property real  scale: 1.0
    property int   fillMode: Image.PreserveAspectFit

    // ???? width/height ??? ? ???? ?? ??? scale ??
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
        transform: Scale {
            origin.x: img.width / 2
            origin.y: img.height / 2
            xScale: root.mirror ? -root.scale : root.scale
            yScale: root.scale
        }
    }
}
