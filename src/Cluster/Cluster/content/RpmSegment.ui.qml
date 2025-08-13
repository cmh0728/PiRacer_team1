// content/RpmSegment.ui.qml
import QtQuick 6.4

Item {
    id: root
    // 기존 ColorizedImage와 호환되는 속성들
    property url   source: "../images/big/tacho/6.png"   // ← 기본값 지정 (원래 쓰던 경로)
    property color color: "#ffffff"                      // (주의) .ui.qml에서는 틴트 미지원 → 현재 미사용
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

        // 좌우 반전 + 스케일 (함수 호출 없이)
        transform: Scale {
            origin.x: img.width / 2
            origin.y: img.height / 2
            xScale: root.mirror ? -root.scale : root.scale
            yScale: root.scale
        }
    }
}
