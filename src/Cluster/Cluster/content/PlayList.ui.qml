import QtQuick 6.4
import QtQuick.Controls 6.4
import Qt.labs.folderlistmodel 1.0
import QtQuick.Layouts 6.4

Rectangle {
    id: playlistBox
    width: 400
    height: 200
    color: "transparent"
    radius: 16
    scale: 0.8
    clip: true

    // === 상태/옵션 ===
    property bool isPlaying: true
    property bool autoProgress: isPlaying // 재생 상태와 동기화
    property int currentIndex: 0
    property int slotPadding: 10
    property int albumFillMode: Image.PreserveAspectFit

    // === 재생 정보 ===
    property int totalPlaybackDuration: 223
    property real currentPlaybackTime: 0
    property string trackTitle: "Song Title"
    property string trackArtist: "Artist"

    // 트랙 변경 시 0초로 리셋 (단일 표현식)
    onCurrentIndexChanged: currentPlaybackTime = 0

    // === 시간 포맷 (함수 호출 없이) ===
    property int curMin: (currentPlaybackTime / 60) | 0
    property int curSec: (currentPlaybackTime % 60) | 0
    property int totMin: (totalPlaybackDuration / 60) | 0
    property int totSec: (totalPlaybackDuration % 60) | 0
    property string curTimeText: (curMin < 10 ? "0" : "") + curMin + ":"
                                 + (curSec < 10 ? "0" : "") + curSec
    property string totTimeText: (totMin < 10 ? "0" : "") + totMin + ":"
                                 + (totSec < 10 ? "0" : "") + totSec
    property int progressPercent: totalPlaybackDuration > 0 ? ((currentPlaybackTime * 100
                                                                / totalPlaybackDuration) | 0) : 0

    // === 초 단위 자동 진행 (단일 표현식) ===
    Timer {
        id: progressTimer
        interval: 1000
        running: autoProgress
        repeat: true
        onTriggered: currentPlaybackTime = currentPlaybackTime
                     < totalPlaybackDuration ? currentPlaybackTime + 1 : totalPlaybackDuration
    }

    // === 앨범 이미지 모델 ===
    FolderListModel {
        id: playlistImages
        folder: "../images/albums/"
        nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.JPG", "*.PNG", "*.JPEG"]
        showDirs: false
    }

    // ===== 상단 콘텐츠 영역 (Album slot + 정보 패널) =====
    Rectangle {
        id: albumSlot
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: controlsBar.top // ▼ 버튼바 위까지
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 19
        anchors.bottomMargin: 8 // 버튼바와 살짝 간격
        radius: 12
        color: Qt.rgba(0, 0, 0, 0.35)
        border.color: Qt.rgba(255, 255, 255, 0.15)
        border.width: 1
        clip: true

        // 좌측: 앨범 이미지
        Rectangle {
            id: albumImageArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: rightInfoPanel.left
            anchors.margins: slotPadding
            anchors.rightMargin: 6
            radius: 10
            color: "transparent"
            clip: true

            Repeater {
                model: playlistImages
                Image {
                    anchors.fill: parent
                    source: fileURL
                    fillMode: albumFillMode
                    sourceSize.width: width
                    sourceSize.height: height
                    smooth: true
                    mipmap: true
                    cache: true
                    asynchronous: true
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    visible: index === playlistBox.currentIndex
                }
            }

            Text {
                anchors.centerIn: parent
                text: playlistImages.count === 0 ? "이미지가 없습니다" : ""
                color: "#bdbdbd"
                font.pixelSize: 14
                visible: playlistImages.count === 0
            }
        }

        // 우측: 제목/아티스트/시간/진행바
        Rectangle {
            id: rightInfoPanel
            x: 117
            width: 245
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: slotPadding
            radius: 10
            color: Qt.rgba(0, 0, 0, 0.4)
            border.color: Qt.rgba(255, 255, 255, 0.1)
            border.width: 1
            clip: true

            Text {
                id: titleLabel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                text: trackTitle
                color: "white"
                font.pixelSize: 16
                font.bold: true
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }

            Text {
                id: artistLabel
                anchors.top: titleLabel.bottom
                anchors.left: titleLabel.left
                anchors.right: titleLabel.right
                anchors.topMargin: 6
                text: trackArtist
                color: "#cfcfcf"
                font.pixelSize: 13
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
            }

            RowLayout {
                id: timeRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: progressBar.top
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.bottomMargin: 6
                spacing: 6

                Text {
                    text: curTimeText
                    color: "#dddddd"
                    font.pixelSize: 12
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: progressPercent + "%"
                    color: "#aaaaaa"
                    font.pixelSize: 12
                }
                Text {
                    text: totTimeText
                    color: "#888888"
                    font.pixelSize: 12
                }
            }

            ProgressBar {
                id: progressBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.bottomMargin: 10
                from: 0
                to: totalPlaybackDuration
                value: currentPlaybackTime
                implicitHeight: 10
            }
        }
    }

    // ===== 하단 컨트롤 바 (Album slot 밖, playlistBox 하단) =====
    Rectangle {
        id: controlsBar
        height: 40
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.bottomMargin: 12
        radius: 8
        color: Qt.rgba(0, 0, 0, 0.28)
        border.color: Qt.rgba(255, 255, 255, 0.08)
        border.width: 1
        clip: true

        Row {
            id: controlsRow
            anchors.centerIn: parent
            spacing: 16

            // 공통 아이콘 컬러
            property color iconColor: "#d0d0d0"
            property color hoverColor: "#ffffff"

            // === Prev (세모 1개 + 세로바) ===
            Item {
                id: prevBtn
                width: 28
                height: 28

                // 세로바 (왼쪽)
                Rectangle {
                    width: 3
                    height: 18
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    color: prevArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: 0.95
                }
                // 삼각형 (바와 거의 붙게)
                Text {
                    text: "◀"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 6 // 바(3px)+여백(1px) 정도로 붙임
                    color: prevArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: 0.95
                }

                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentIndex = playlistImages.count
                               > 0 ? (currentIndex > 0 ? currentIndex
                                                         - 1 : playlistImages.count - 1) : 0
                }
            }

            // === Play (▶) ===
            Item {
                id: playBtn
                width: 28
                height: 28

                Text {
                    text: "▶"
                    font.pixelSize: 20
                    anchors.centerIn: parent
                    color: playArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: isPlaying ? 0.4 : 1.0
                }

                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: isPlaying = true
                }
            }

            // === Pause (⏸) ===
            Item {
                id: pauseBtn
                width: 28
                height: 28

                Rectangle {
                    width: 6
                    height: 18
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 7
                    color: pauseArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: !isPlaying ? 0.4 : 1.0
                }
                Rectangle {
                    width: 6
                    height: 18
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 7
                    color: pauseArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: !isPlaying ? 0.4 : 1.0
                }

                MouseArea {
                    id: pauseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: isPlaying = false
                }
            }

            // === Next (세모 1개 + 세로바) ===
            Item {
                id: nextBtn
                width: 28
                height: 28

                // 삼각형 (오른쪽 바라보는)
                Text {
                    text: "▶"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    color: nextArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: 0.95
                }
                // 세로바 (오른쪽, 삼각형에 붙게)
                Rectangle {
                    width: 3
                    height: 18
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    color: nextArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: 0.95
                }

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentIndex = playlistImages.count
                               > 0 ? (currentIndex + 1
                                      < playlistImages.count ? currentIndex + 1 : 0) : 0
                }
            }
        }
    }

    // (옵션) 디버그


    /*
    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
        text: "idx: " + currentIndex + " / count: " + playlistImages.count
        color: "#cfcfcf"
        font.pixelSize: 12
        opacity: 0.6
    }
    */
}
