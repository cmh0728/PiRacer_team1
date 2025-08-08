// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.4
import Cluster
import QtQuick.Controls 6.5

Window {
    id : root
    width: mainScreen.width
    height: mainScreen.height
    visible: true
    title: "Cluster"

    property real rpmSmooth: 0  

    StackView{
        
        id: stack
        anchors.fill: parent
        initialItem: Qt.resolvedUrl("Screen01.qml")
    }

    //Screen01 binding
    Screen01 {
        id: mainScreen
        x: 0
        y: 0
        color: "#000000"
        // rpmValue: canReceiver.rpm
        rpmValue: rpmSmooth
        speedValue: canReceiver.speed
        batteryValue: canReceiver.batteryPercent
        gearValue: canReceiver.gear

        Button {
            id: button
            x: 1201
            y: 17
            text: qsTr("mode")
        }
    }
    // RPM 
    NumberAnimation {
        id: rpmAnim
        target: root
        property: "rpmSmooth"
        duration: 300
        easing.type: Easing.InOutQuad
    }

    Connections {
        target: canReceiver
        function onRpmChanged() {
            // console.log("🔄 RPM Changed:", canReceiver.rpm) //debugging
            rpmSmooth = canReceiver.rpm   
            rpmAnim.restart()
        }
    }

}

