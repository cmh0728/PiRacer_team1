
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.4
import QtQuick.Controls 6.4
import Cluster
import QtQuick.Layouts

Rectangle {
    id: rectangle
    property real rpmValue: 0
    property real speedValue: 0
    property real batteryValue: 0
    property int gearValue: 3
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
        // source: "qrc:/images/gauge-gauge-frame-sport-center.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: rpm_guage
        x: 42
        y: 13
        width: 597
        height: 379
        source: "../images/gauge-gauge-frame-sport-side.png"
        // source: "qrc:/images/gauge-gauge-frame-sport-side.png"
        fillMode: Image.PreserveAspectFit

        Text {
            id: speed
            x: 560
            y: 209
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "cm/s"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            clip: true
        }

        Text {
            id: rpm
            x: 242
            y: 173
            width: 81
            height: 35
            color: "#b7b2b2"
            text: "RPM"
            font.pixelSize: 26
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
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
            text: "20"
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
            text: "40"
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
            text: "100"
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
            text: "120"
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
            text: "80"
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
            // source: "qrc:/images/red-border-right.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 96 //rpm_center 기반의 계산
                    origin.y: 190
                    //angle: rectangle.rpmValue * 0.18 + 17
                    angle: rectangle.rpmValue * 0.15 * 0.5 - 142 // <- 회전 각도 연결
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

            // source: "qrc:/images/highlight-standard-sport.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 78 // = rpm_center.x + 50 - rpm_hl.x
                    origin.y: 235 // = rpm_center.y + 50 - rpm_hl.y
                    angle: rectangle.rpmValue * 0.15 * 0.5 - 162
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

            // source: "qrc:/images/red-border-right.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 90 // speed_center의 x + width / 2
                    origin.y: 215 // speed_center의 y + height / 2
                    angle: rectangle.speedValue * 7 * 0.25 - 88 // speedValue에 따른 회전 각도 계산
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

            // source: "qrc:/images/highlight-standard-sport.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 74
                    origin.y: 255
                    angle: rectangle.speedValue * 7 * 0.25 - 108
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

            // source: "qrc:/images/bg-mask.png"
            fillMode: Image.PreserveAspectFit

            Image {
                id: car_highlight
                x: 11
                y: 10
                width: 318
                height: 309
                source: "../images/car-highlights.png"

                // source: "qrc:/images/car-highlights.png"
                fillMode: Image.PreserveAspectFit

                Text {
                    id: drive_mode_P
                    x: 54
                    y: 105
                    width: 47
                    height: 41
                    color: rectangle.gearValue === 3 ? "#ffffff" : "#7f7f7f"
                    text: "P"
                    font.pixelSize: 32
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                Text {
                    id: drive_mode_D
                    x: 107
                    y: 105
                    width: 47
                    height: 41
                    color: rectangle.gearValue === 1 ? "#ffffff" : "#7f7f7f"
                    text: "D"
                    font.pixelSize: 32
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                Text {
                    id: drive_mode_N
                    x: 160
                    y: 105
                    width: 47
                    height: 41
                    color: rectangle.gearValue === 0 ? "#ffffff" : "#7f7f7f"
                    text: "N"
                    font.pixelSize: 32
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                Text {
                    id: drive_mode_R
                    x: 213
                    y: 105
                    width: 47
                    height: 41
                    color: rectangle.gearValue === 2 ? "#ffffff" : "#7f7f7f"
                    text: "R"
                    font.pixelSize: 32
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }
            }
        }

        Text {
            id: speed_display
            x: 515
            y: 140
            width: 171
            height: 54
            color: "#f7f0f0"
            font.pixelSize: 45
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            text: rectangle.speedValue.toFixed(0)

            // 소수점 없이 정수로 출력
        }
    }

    Image {
        id: battery_guage
        x: 645
        y: 13
        width: 597
        height: 379
        source: "../images/gauge-gauge-frame-sport-side-copy.png"

        // source: "qrc:/images/gauge-gauge-frame-sport-side-copy.png"
        fillMode: Image.PreserveAspectFit

        Image {
            id: battery
            x: 272
            y: 173
            width: 53
            height: 34
            source: "../images/battery.png"

            // source: "qrc:/images/battery.png"
            fillMode: Image.PreserveAspectFit
            Rectangle {
                id: battery_fill
                width: parent.width * 0.4 * 0.9
                height: parent.height * (rectangle.batteryValue / 100) * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: "lime"
                radius: 2
                z: -1 // 배터리 이미지보다 뒤에 그리려면 필요 없을 수도 있음
                opacity: 0.8
            }
        }

        Image {
            id: battery_needle
            x: 294
            y: -1
            width: 96
            height: 126
            source: "../images/red-border-left.png"

            // source: "qrc:/images/red-border-left.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    angle: -1 * rectangle.batteryValue * 1.8 + 160 //0~100 -> 0~180도
                    origin.x: 0
                    origin.y: 193
                }
            ]
        }

        Image {
            id: battery_hl
            x: 222
            y: -45
            width: 156
            height: 137
            source: "../images/highlight-standard-sport.png"

            // source: "qrc:/images/highlight-standard-sport.png"
            fillMode: Image.PreserveAspectFit
            transform: [
                Rotation {
                    origin.x: 294 - 221 + 3
                    // battery_needle.x - battery_hl.x + battery_needle.origin.x
                    origin.y: -1 - (-45)
                              + 190 // battery_needle.y - battery_hl.y + battery_needle.origin.y
                    angle: -1 * rectangle.batteryValue * 1.8 - 181
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
        text: "60"
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
        text: "500"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }

    Text {
        id: rpm_500
        x: 150
        y: 183
        width: 81
        height: 35
        color: "#b7b2b2"
        text: "1000"
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
        text: "1500"
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
        text: "2000"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }
}
