// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.4
import Cluster

Window {
    width: mainScreen.width
    height: mainScreen.height
    visible: true
    title: "Cluster"

    Screen01 {
        id: mainScreen
        color: "#000000"
        rpmValue: 0
        speedValue: 0
        batteryValue: 0
    }
    // RPM 애니메이션
        SequentialAnimation {
            running: true
            loops: Animation.Infinite
            NumberAnimation { target: mainScreen; property: "rpmValue"; from: 0; to: 1000; duration: 3000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: mainScreen; property: "rpmValue"; from: 1000; to: 0; duration: 3000; easing.type: Easing.InOutQuad }
        }

        // 속도 애니메이션
        SequentialAnimation {
            running: true
            loops: Animation.Infinite
            NumberAnimation { target: mainScreen; property: "speedValue"; from: 0; to: 30; duration: 2000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: mainScreen; property: "speedValue"; from: 30; to: 0; duration: 2000; easing.type: Easing.InOutQuad }
        }

        // 배터리 애니메이션
        SequentialAnimation {
            running: true
            loops: Animation.Infinite
            NumberAnimation { target: mainScreen; property: "batteryValue"; from: 0; to: 100; duration: 5000; easing.type: Easing.InOutQuad }
            NumberAnimation { target: mainScreen; property: "batteryValue"; from: 100; to: 0; duration: 5000; easing.type: Easing.InOutQuad }
        }
}

