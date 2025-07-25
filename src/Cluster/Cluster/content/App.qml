// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.5
import Cluster

Window {
    width: mainScreen.width
    height: mainScreen.height

    visible: true
    title: "Cluster"

    Screen01 {
        id: mainScreen
        color: "#000000"
    }

}

