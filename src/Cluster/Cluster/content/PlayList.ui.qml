import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 6.4
import QtQml 6.4

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
    property int currentIndex: 0
    property int slotPadding: 10
    property int albumFillMode: Image.PreserveAspectFit

    // === 재생 정보 ===
    property int totalPlaybackDuration: 223
    property real currentPlaybackTime: 0

    // 트랙 변경 시 0초로 리셋
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

    // === 초 단위 자동 진행 ===
    Timer {
        id: progressTimer
        interval: 1000
        running: isPlaying
        repeat: true
        onTriggered: currentPlaybackTime = currentPlaybackTime
                     < totalPlaybackDuration ? currentPlaybackTime + 1 : currentPlaybackTime
    }

    // 끝에 도달하면 한 번만 다음 곡으로
    Timer {
        id: nextTrackTimer
        interval: 0
        repeat: false
        running: isPlaying && (currentPlaybackTime >= totalPlaybackDuration)
        onTriggered: currentIndex = playlistImages.count
                     > 0 ? ((currentIndex + 1) < playlistImages.count ? currentIndex + 1 : 0) : 0
    }

    // === 앨범 모델 (qrc 경로 사용) ===
    // 상대경로로 쓰고 싶으면 아래 "../images/..." 를 "../images/..." 로 바꿔도 됩니다.
    ListModel {
        id: playlistImages
        ListElement {
            fileURL: "../images/albums/195.jpg"
            trackArtist: "RAC"
            trackTitle: "195"
        }
        ListElement {
            fileURL: "../images/albums/2020.jpg"
            trackArtist: "Samaris"
            trackTitle: "2020"
        }
        ListElement {
            fileURL: "../images/albums/aerosmith.jpg"
            trackArtist: "Aerosmith"
            trackTitle: "Dream On"
        }
        ListElement {
            fileURL: "../images/albums/appetite.jpg"
            trackArtist: "Guns N' Roses"
            trackTitle: "Sweet Child O' Mine"
        }
        ListElement {
            fileURL: "../images/albums/astral.jpg"
            trackArtist: "Astral Tales"
            trackTitle: "Voyage"
        }
        ListElement {
            fileURL: "../images/albums/atrey.jpg"
            trackArtist: "Atreyu"
            trackTitle: "Becoming The Bull"
        }
        ListElement {
            fileURL: "../images/albums/bangles.jpg"
            trackArtist: "The Bangles"
            trackTitle: "Manic Monday"
        }
        ListElement {
            fileURL: "../images/albums/beast.jpg"
            trackArtist: "Beastie Boys"
            trackTitle: "Sabotage"
        }
        ListElement {
            fileURL: "../images/albums/born.jpg"
            trackArtist: "Bruce Springsteen"
            trackTitle: "Born in the U.S.A."
        }
        ListElement {
            fileURL: "../images/albums/callme.jpg"
            trackArtist: "Blondie"
            trackTitle: "Call Me"
        }
        ListElement {
            fileURL: "../images/albums/cyberpunk.jpg"
            trackArtist: "Cyberpunk 2077 OST"
            trackTitle: "Chippin' In"
        }
        ListElement {
            fileURL: "../images/albums/doomsday.jpg"
            trackArtist: "Nero"
            trackTitle: "Doomsday"
        }
        ListElement {
            fileURL: "../images/albums/drift.jpg"
            trackArtist: "Carpenter Brut"
            trackTitle: "Turbo Killer"
        }
        ListElement {
            fileURL: "../images/albums/duett.jpg"
            trackArtist: "Duett"
            trackTitle: "Horizons"
        }
        ListElement {
            fileURL: "../images/albums/escape.jpg"
            trackArtist: "INYAN"
            trackTitle: "Escape"
        }
        ListElement {
            fileURL: "../images/albums/exploration.jpg"
            trackArtist: "Timecop1983"
            trackTitle: "Exploration"
        }
        ListElement {
            fileURL: "../images/albums/firebird.jpg"
            trackArtist: "Dance With The Dead"
            trackTitle: "Firebird"
        }
        ListElement {
            fileURL: "../images/albums/gunship.jpg"
            trackArtist: "GUNSHIP"
            trackTitle: "Tech Noir"
        }
        ListElement {
            fileURL: "../images/albums/holo.jpg"
            trackArtist: "HOME"
            trackTitle: "Resonance"
        }
        ListElement {
            fileURL: "../images/albums/hunting.jpg"
            trackArtist: "The Midnight"
            trackTitle: "Hunting Season"
        }
        ListElement {
            fileURL: "../images/albums/language.jpg"
            trackArtist: "Porter Robinson"
            trackTitle: "Language"
        }
        ListElement {
            fileURL: "../images/albums/LAU.jpg"
            trackArtist: "LAU"
            trackTitle: "True"
        }
        ListElement {
            fileURL: "../images/albums/lebrock.jpg"
            trackArtist: "LeBrock"
            trackTitle: "Runaway"
        }
        ListElement {
            fileURL: "../images/albums/megawave.jpg"
            trackArtist: "FM-84"
            trackTitle: "Bend & Break"
        }
        ListElement {
            fileURL: "../images/albums/melez.jpg"
            trackArtist: "Melez"
            trackTitle: "Afterglow"
        }
        ListElement {
            fileURL: "../images/albums/motel.jpg"
            trackArtist: "Moonrunner83"
            trackTitle: "Motel"
        }
        ListElement {
            fileURL: "../images/albums/nofuture.jpg"
            trackArtist: "Com Truise"
            trackTitle: "Propagation"
        }
        ListElement {
            fileURL: "../images/albums/ocular.jpg"
            trackArtist: "Wice"
            trackTitle: "Ocular"
        }
        ListElement {
            fileURL: "../images/albums/patti.jpg"
            trackArtist: "Patti Smith"
            trackTitle: "Because the Night"
        }
        ListElement {
            fileURL: "../images/albums/pylot.jpg"
            trackArtist: "PYLOT"
            trackTitle: "With Me"
        }
        ListElement {
            fileURL: "../images/albums/runthe.jpg"
            trackArtist: "Run The Jewels"
            trackTitle: "Legend Has It"
        }
        ListElement {
            fileURL: "../images/albums/scandroid.jpg"
            trackArtist: "Scandroid"
            trackTitle: "Shout"
        }
        ListElement {
            fileURL: "../images/albums/slippery.jpg"
            trackArtist: "Bon Jovi"
            trackTitle: "Livin' on a Prayer"
        }
        ListElement {
            fileURL: "../images/albums/visions.jpg"
            trackArtist: "Stranger Things OST"
            trackTitle: "Kids"
        }
        ListElement {
            fileURL: "../images/albums/waves.jpg"
            trackArtist: "Mr. Probz"
            trackTitle: "Waves"
        }
    }

    // ===== 상단 콘텐츠 영역 =====
    Rectangle {
        id: albumSlot
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: controlsBar.top
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 19
        anchors.bottomMargin: 8
        radius: 12
        color: Qt.rgba(0, 0, 0, 0.35)
        border.color: Qt.rgba(255, 255, 255, 0.15)
        border.width: 1
        clip: true

        // 좌측: 앨범 이미지 (ListView로 현재 인덱스 강제 노출)
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

            ListView {
                id: albumView
                anchors.fill: parent
                model: playlistImages
                currentIndex: playlistBox.currentIndex
                interactive: false
                orientation: ListView.Horizontal
                boundsBehavior: Flickable.StopAtBounds
                snapMode: ListView.SnapOneItem
                clip: true

                // ★ currentIndex가 화면에 꼭 보이도록 강제
                focus: true
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: width
                highlightMoveDuration: 0
                cacheBuffer: width

                delegate: Item {
                    // 모델 역할을 delegate 속성으로 그대로 받기(.ui.qml OK)
                    required property string fileURL
                    required property string trackTitle
                    required property string trackArtist

                    width: albumView.width
                    height: albumView.height

                    Image {
                        anchors.fill: parent
                        source: fileURL
                        fillMode: playlistBox.albumFillMode
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        cache: true
                        mipmap: true
                    }
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
                // ★ 함수 호출 없이 현재 delegate의 role 접근
                text: albumView.currentItem ? albumView.currentItem.trackTitle : ""
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
                text: albumView.currentItem ? albumView.currentItem.trackArtist : ""
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

    // ===== 하단 컨트롤 바 =====
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

            property color iconColor: "#d0d0d0"
            property color hoverColor: "#ffffff"

            // Prev (◀|)
            Item {
                width: 28
                height: 28
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
                Text {
                    text: "◀"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 6
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

            // Play (▶)
            Item {
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

            // Pause (⏸)
            Item {
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

            // Next (|▶)
            Item {
                width: 28
                height: 28
                Rectangle {
                    width: 3
                    height: 18
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    color: nextArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: 0.95
                }
                Text {
                    text: "▶"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    color: nextArea.containsMouse ? controlsRow.hoverColor : controlsRow.iconColor
                    opacity: 0.95
                }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentIndex = playlistImages.count
                               > 0 ? ((currentIndex + 1)
                                      < playlistImages.count ? currentIndex + 1 : 0) : 0
                }
            }
        }
    }
}
