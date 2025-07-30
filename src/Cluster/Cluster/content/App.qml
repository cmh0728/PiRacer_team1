// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.4
import Cluster

Window {
    width: mainScreen.width
    height: mainScreen.height
    visible: true
    title: "Cluster"

    property real rpmSmooth: 0  

    Screen01 {
        id: mainScreen
        color: "#000000"
        // rpmValue: canReceiver.rpm
        rpmValue: rpmSmooth
        speedValue: canReceiver.speed
        batteryValue: 0
    }
    // RPM 애니메이션
    NumberAnimation on rpmSmooth {
        id: rpmAnim
        duration: 300
        easing.type: Easing.InOutQuad
    }


    // battery
    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        NumberAnimation { target: mainScreen; property: "batteryValue"; from: 0; to: 100; duration: 5000; easing.type: Easing.InOutQuad }
        NumberAnimation { target: mainScreen; property: "batteryValue"; from: 100; to: 0; duration: 5000; easing.type: Easing.InOutQuad }
    }
}

