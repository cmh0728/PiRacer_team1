// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.4
import Cluster

Window {
    id : root
    width: mainScreen.width
    height: mainScreen.height
    visible: true
    title: "Cluster"

    property real rpmSmooth: 0  

    //Screen01 binding
    Screen01 {
        id: mainScreen
        anchors.fill: parent
        color: "#000000"
        // rpmValue: canReceiver.rpm
        rpmValue: rpmSmooth
        speedValue: canReceiver.speed
        batteryValue: 0
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
            // console.log("🔄 RPM Changed:", canReceiver.rpm)
            rpmSmooth = canReceiver.rpm   // 직접 값을 할당해 → Behavior가 애니메이션 처리
            rpmAnim.restart()
        }
    }

    // battery
    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        NumberAnimation { target: mainScreen; property: "batteryValue"; from: 0; to: 100; duration: 5000; easing.type: Easing.InOutQuad }
        NumberAnimation { target: mainScreen; property: "batteryValue"; from: 100; to: 0; duration: 5000; easing.type: Easing.InOutQuad }
    }
}

