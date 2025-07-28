
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
        id: speed_guage
        x: 335
        y: 8
        width: 610
        height: 446
        source: "../images/gauge-gauge-frame-sport-center.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: rpm_guage
        x: 42
        y: 13
        width: 597
        height: 379
        source: "../images/gauge-gauge-frame-sport-side.png"
        fillMode: Image.PreserveAspectFit

        Text {
            id: speed
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
            id: rpm
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
            id: battery_100
            x: 865
            y: 18
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "100%"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: battery_0
            x: 865
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
            id: speed_0
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
            id: speed_5
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
            id: speed_10
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
            id: speed_25
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
            id: speed_30
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
            id: speed_20
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
            x: 203
            y: 0
            width: 96
            height: 126
            source: "../images/red-border-right.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 96 //rpm_center 기반의 계산
                    origin.y: 190
                    //angle: rectangle.rpmValue * 0.18 + 17
                    angle: rectangle.rpmValue * 0.18 - 142 // <- 회전 각도 연결
                }
            ]
        }

        Image {
            id: rpm_hl
            x: 221
            y: -45
            width: 156
            height: 137
            source: "../images/highlight-standard-sport.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 78 // = rpm_center.x + 50 - rpm_hl.x
                    origin.y: 235 // = rpm_center.y + 50 - rpm_hl.y
                    angle: rectangle.rpmValue * 0.18 - 162
                }
            ]
        }

        Image {
            id: speed_needle
            x: 507
            y: 0
            width: 96
            height: 126
            source: "../images/red-border-right.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 90 // speed_center의 x + width / 2
                    origin.y: 215 // speed_center의 y + height / 2
                    angle: rectangle.speedValue * 6 - 88 // speedValue에 따른 회전 각도 계산
                }
            ]
        }
        Image {
            id: speed_hl
            x: 523
            y: -40
            width: 156
            height: 137
            source: "../images/highlight-standard-sport.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 74
                    origin.y: 255
                    angle: rectangle.speedValue * 6 - 108
                }
            ]
        }

        Image {
            id: car_img
            x: 431
            y: 157
            width: 339
            height: 327
            source: "../images/bg-mask.png"
            fillMode: Image.PreserveAspectFit

            Image {
                id: car_highlight
                x: 11
                y: 10
                width: 318
                height: 309
                source: "../images/car-highlights.png"
                fillMode: Image.PreserveAspectFit

                Text {
                    id: text1
                    x: 74
                    y: 90
                    width: 171
                    height: 54
                    color: "#f7f0f0"
                    text: qsTr("D N R P")
                    font.pixelSize: 25
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Image {
        id: battery_guage
        x: 645
        y: 13
        width: 597
        height: 379
        source: "../images/gauge-gauge-frame-sport-side 복사본.png"
        fillMode: Image.PreserveAspectFit

        Image {
            id: battery
            x: 258
            y: 172
            width: 81
            height: 35
            source: "../images/battery.png"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: battery_needle
            x: 294
            y: -1
            width: 96
            height: 126
            source: "../images/red-border-left.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    angle: rectangle.batteryValue * 1.8 - 20 //0~100 -> 0~180도
                    origin.x: -1
                    origin.y: 193
                }
            ]
        }

        Image {
            id: battery_hl
            x: 221
            y: -45
            width: 156
            height: 137
            source: "../images/highlight-standard-sport.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 294 - 221
                    // battery_needle.x - battery_hl.x + battery_needle.origin.x
                    origin.y: -1 - (-45)
                              + 190 // battery_needle.y - battery_hl.y + battery_needle.origin.y
                    angle: rectangle.batteryValue * 1.8 - 1
                }
            ]
        }
    }

    Text {
        id: speed_15
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
        id: rpm_0
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
        id: rpm_250
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
        id: rpm_500
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
        id: rpm_750
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
        id: rpm_1000
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
