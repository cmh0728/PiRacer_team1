import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 6.4
import Cluster

Window {
    id: root
    width: Constants.width
    height: Constants.height
    visible: true; title: "Cluster"

    // Layout for screen change
    StackLayout {
        id: screenStack
        anchors.fill: parent

        // index 0 : Screen01
        Screen01 {
            id: screen01
            rpmValue: rpmSmooth
            speedValue: canReceiver.speed
            batteryValue: canReceiver.batteryPercent
            gearValue: canReceiver.gear
        }

        // index 1 : Screen02
        Screen02 {
            id: screen02
            speedValue: canReceiver.speed
        }
    }

    // button click --> mode change to index
    /*
    Button {
        id: modeBtn
        x: 1202
        text: qsTr("mode")
        anchors.rightMargin: 24
        anchors.topMargin: 19
        anchors { right: parent.right; top: parent.top; margins: 20 }
        onClicked: {
            // index change between 0 and 1
            screenStack.currentIndex = (screenStack.currentIndex + 1) % screenStack.count
        }
    }
    */

    Connections {
        target: screen01
        function onModeToggleChanged() {
            screenStack.currentIndex = screenStack.currentIndex === 0 ? 1 : 0
        }
    }
    Connections {
        target: screen02
        function onModeToggleChanged() {
            screenStack.currentIndex = screenStack.currentIndex === 0 ? 1 : 0
        }
    }


    // RPM animation (기존 그대로)
    property real rpmSmooth: 0
    NumberAnimation {
        id: rpmAnim; target: root; property: "rpmSmooth"
        duration: 300; easing.type: Easing.InOutQuad
    }
    Connections {
        target: canReceiver
        function onRpmChanged() {
            rpmSmooth = canReceiver.rpm
            rpmAnim.restart()
        }
    }
}
