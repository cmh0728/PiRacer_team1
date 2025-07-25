
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.5
import QtQuick.Controls 6.5
import Cluster
import QtQuick.Layouts

Rectangle {
    id: rectangle
    property real rpmValue: 0
    property real speedValue: 0
    property real batteryValue: 0
    width: Constants.width
    height: Constants.height
    color: "#000000"

    Image {
        id: image
        x: 335
        y: 8
        width: 610
        height: 446
        source: "../images/gauge-gauge-frame-sport-center.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: image1
        x: 42
        y: 13
        width: 597
        height: 379
        source: "../images/gauge-gauge-frame-sport-side.png"
        fillMode: Image.PreserveAspectFit

        Text {
            id: text1
            x: 560
            y: 172
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "cm/s"
            font.pixelSize: 26
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text2
            x: 258
            y: 172
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "rpm "
            font.pixelSize: 26
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text3
            x: 881
            y: 16
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "100%"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text4
            x: 881
            y: 336
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "0%"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text5
            x: 383
            y: 253
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "0"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text6
            x: 383
            y: 149
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "5"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text7
            x: 441
            y: 62
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "10"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text8
            x: 733
            y: 149
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "25"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text9
            x: 733
            y: 253
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "30"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: text10
            x: 678
            y: 62
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "20"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Image {
            id: rpm_needle
            x: 201
            y: 0
            width: 96
            height: 126
            source: "../images/red-border-right.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: rpm_needle.width / 2
                    origin.y: rpm_needle.height
                    angle: rectangle.rpmValue * 0.18 // <- 회전 각도 연결
                }
            ]
        }

        Image {
            id: speed_needle
            x: 506
            y: 0
            width: 96
            height: 126
            source: "../images/red-border-right.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    angle: rectangle.speedValue * 6
                    origin.y: speed_needle.height
                    origin.x: speed_needle.width / 2
                }
            ]
        }
    }

    Image {
        id: image2
        x: 645
        y: 13
        width: 597
        height: 379
        source: "../images/gauge-gauge-frame-sport-side 복사본.png"
        fillMode: Image.PreserveAspectFit

        Image {
            id: image3
            x: 272
            y: 172
            width: 81
            height: 35
            source: "../images/battery.png"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: battery_needle
            x: 310
            y: 0
            width: 96
            height: 126
            source: "../images/red-border-left.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    angle: rectangle.batteryValue * 1.8 //0~100 -> 0~180도
                    origin.y: battery_needle.height
                    origin.x: battery_needle.width / 2
                }
            ]
        }
    }

    Text {
        id: text11
        x: 600
        y: 28
        width: 81
        height: 35
        color: "#b7b2b2"
        text: "15"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }

    Text {
        id: text12
        x: 254
        y: 344
        width: 81
        height: 35
        color: "#b7b2b2"
        text: "0"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }

    Text {
        id: text13
        x: 182
        y: 280
        width: 81
        height: 35
        color: "#b7b2b2"
        text: "250"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }

    Text {
        id: text14
        x: 145
        y: 191
        width: 81
        height: 35
        color: "#b7b2b2"
        text: "500"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }

    Text {
        id: text15
        x: 182
        y: 93
        width: 81
        height: 35
        color: "#b7b2b2"
        text: "750"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }

    Text {
        id: text16
        x: 254
        y: 37
        width: 81
        height: 35
        color: "#b7b2b2"
        text: "1000"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }
}
