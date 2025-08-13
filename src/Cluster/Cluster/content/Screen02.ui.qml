import QtQuick 6.4
import QtQuick.Controls 6.4

Rectangle {
    id: rectangle

    width: 1280
    height: 400
    color: "#101010"
    anchors.fill: parent
    property alias rpmbottom: rpmbottom

    property real speedValue: 0
    property bool showPlayer: false
    property bool modeToggle: modeBtn.trigger

    Image {
        id: background
        visible: true
        anchors.fill: parent
        source: "../images/big/bg/main.png"
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
    }

    AnimatedImage {
        id: animatedImage
        x: 408
        y: 143
        width: 464
        height: 244
        source: "../images/big/welcome/road.png"
        scale: 0.8
    }

    AnimatedImage {
        id: leftline
        x: 337
        y: 133
        width: 296
        height: 263
        source: "../images/big/welcome/left-lines.png"
        scale: 0.8
    }

    AnimatedImage {
        id: rightline
        x: 653
        y: 126
        width: 285
        height: 271
        source: "../images/big/welcome/right-lines.png"
        scale: 0.8
    }
    Item {
        id: internal
        property color colorA: "#ffffff"
        property color colorB: "#f94a07"
    }

    Text {
        id: label_0
        x: 66
        y: 113
        color: internal.colorA
        text: qsTr("0")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_1
        x: 129
        y: 87
        color: internal.colorA
        text: qsTr("1")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }

    Text {
        id: label_2
        x: 192
        y: 59
        color: internal.colorA
        text: qsTr("2")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_3
        x: 255
        y: 35
        color: internal.colorA
        text: qsTr("3")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }

    Text {
        id: label_4
        x: 326
        y: 17
        color: internal.colorA
        text: qsTr("4")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_5
        x: 402
        y: 13
        color: internal.colorA
        text: qsTr("5")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }

    Text {
        id: label_6
        x: 481
        y: 14
        color: internal.colorA
        text: qsTr("6")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_7
        x: 557
        y: 14
        color: internal.colorA
        text: qsTr("7")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }

    Text {
        id: label_8
        x: 629
        y: 14
        color: internal.colorA
        text: qsTr("8")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_9
        x: 708
        y: 14
        color: internal.colorA
        text: qsTr("9")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }

    Text {
        id: label_10
        x: 767
        y: 13
        color: internal.colorA
        text: qsTr("10")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_11
        x: 845
        y: 17
        color: internal.colorA
        text: qsTr("11")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }

    Text {
        id: label_12
        x: 919
        y: 33
        color: internal.colorB
        text: qsTr("12")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_13
        x: 989
        y: 61
        color: internal.colorB
        text: qsTr("13")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }

    Text {
        id: label_14
        x: 1054
        y: 91
        color: internal.colorB
        text: qsTr("14")
        font.pixelSize: 33
        font.bold: true
        font.family: "Barlow-mono"
    }

    Text {
        id: label_15
        x: 1115
        y: 120
        color: internal.colorB
        text: qsTr("15")
        font.pixelSize: 33
        font.family: "Barlow-mono"
        font.bold: true
    }
    Item {
        id: segments
        height: 220
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 55
        anchors.rightMargin: 55
        anchors.topMargin: 0

        Rectangle {
            id: colorPlaceHolder1
            x: 10
            y: 14
            width: 50
            height: 50
            visible: false
            color: internal.colorA
        }

        Rectangle {
            id: colorPlaceHolder2
            x: 59
            y: 14
            width: 50
            height: 50
            visible: false
            color: internal.colorB
        }

        // 140km/h를 14개의 세그먼트로 나누어 각 10km/h 단위로 불이 들어오도록 설정
        RpmSegment {
            id: segment_1
            x: 8
            y: 121
            //opacity: 1
            opacity: speedValue > 0 ? 1 : 0
            color: internal.colorA
            source: "../images/big/tacho/1.png"
            scale: 0.8
        }

        RpmSegment {
            id: segment_2
            x: 66
            y: 92
            //opacity: 1
            opacity: speedValue > 10 ? 1 : 0
            source: "../images/big/tacho/2.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_3
            x: 130
            y: 63
            //opacity: 1
            opacity: speedValue > 20 ? 1 : 0
            source: "../images/big/tacho/3.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_4
            x: 194
            y: 40
            //opacity: 1
            opacity: speedValue > 30 ? 1 : 0
            source: "../images/big/tacho/4.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_5
            x: 256
            y: 20
            //opacity: 1
            opacity: speedValue > 40 ? 1 : 0
            source: "../images/big/tacho/5.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_6
            x: 322
            y: 18
            //opacity: 1
            opacity: speedValue > 50 ? 1 : 0
            source: "../images/big/tacho/6.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_7
            x: 398
            y: 18
            //opacity: 1
            opacity: speedValue > 60 ? 1 : 0
            source: "../images/big/tacho/6.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_8
            x: 474
            y: 18
            //opacity: 1
            opacity: speedValue > 75 ? 1 : 0
            source: "../images/big/tacho/6.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_10
            x: 556
            y: 18
            opacity: speedValue > 90 ? 1 : 0
            source: "../images/big/tacho/6.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_11
            x: 632
            y: 18
            //opacity: 1
            opacity: speedValue > 100 ? 1 : 0
            source: "../images/big/tacho/6.png"
            scale: 0.8
            color: internal.colorA
        }

        RpmSegment {
            id: segment_12
            x: 826
            y: 20
            //opacity: 1
            opacity: speedValue > 110 ? 1 : 0
            source: "../images/big/tacho/5.png"
            scale: 0.8
            color: internal.colorA
            mirror: true
        }

        RpmSegment {
            id: segment_13
            x: 894
            y: 31
            //opacity: 1
            opacity: speedValue > 115 ? 1 : 0
            source: "../images/big/tacho/4.png"
            scale: 0.8
            color: internal.colorB
            mirror: true
        }

        RpmSegment {
            id: segment_14
            x: 958
            y: 54
            //opacity: 1
            opacity: speedValue > 120 ? 1 : 0
            source: "../images/big/tacho/3.png"
            scale: 0.8
            color: internal.colorB
            mirror: true
        }

        RpmSegment {
            id: segment_15
            x: 1022
            y: 83
            //opacity: 1
            opacity: speedValue > 125 ? 1 : 0
            source: "../images/big/tacho/2.png"
            scale: 0.8
            color: internal.colorB
            mirror: true
        }

        RpmSegment {
            id: segment_16
            x: 1085
            y: 112
            //opacity: 1
            opacity: speedValue > 130 ? 1 : 0
            source: "../images/big/tacho/1.png"
            scale: 0.8
            color: internal.colorB
            mirror: true
        }

        Tacho {
            id: tacho
            x: 774
            y: 120
            opacity: 1
            scale: 0.35
            speed: speedValue
        }

        Image {
            id: rpmbottom
            x: 49
            y: 138
            width: 1034
            height: 100
            source: "../images/big/welcome/tacho-bottom-line.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            id: rpmtop
            x: -92
            y: 47
            width: 1298
            height: 100
            source: "../images/big/welcome/tacho-top-line.png"
            fillMode: Image.PreserveAspectFit
        }
    }
    // 2) 우하단 뮤직 아이콘 버튼 (열기/닫기 토글)
    MusicToggleButton {
        id: musicBtn
        x: 1161
        y: 5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 65
        anchors.bottomMargin: 341
        size: 36
        scaleFactor: 1.5
    }

    PlayList {
        id: playlistbox
        visible: musicBtn.toggled // ← 버튼 상태로 표시/숨김
        x: 444
        y: 167
        width: 431
        height: 195
        trackTitle: "Drive (feat. Night)"
        trackArtist: "Midnight Club"
        totalPlaybackDuration: 223
        currentPlaybackTime: 0
        currentIndex: 0
        albumFillMode: Image.PreserveAspectCrop
        autoProgress: true // 자동 증가 on/off
    }
    ModeToggleIcon {
        id: modeBtn
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 16
        anchors.topMargin: 16
        iconSize: 32
        // source: "qrc:/images/sport.png"
    }
}
