/****************************************************************************
**
** Copyright (C) 2022 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Design Studio.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick
import QtQuick.Timeline
import MotorClusterData

Item
{
    enum Direction {
        LeftToRight = 0,
        RightToLeft = 1,
        TopToBottom = 2,
        BottomToTop = 3
    }

    id: root
    width: image.width
    height: image.height

    property alias source: image.source

    property int  direction: 0
    property double clipScale: 0.7

    Item
    {
        id: clipper
        clip: true

        width: root.direction < 2 ? root.width * clipScale : root.width
        height: root.direction > 1 ? root.height * clipScale : root.height

        Image {
            id: image
            visible: true

            anchors {
                top: undefined
                right: undefined
                bottom: undefined
                left: undefined

                rightMargin: 0
                bottomMargin: 0
            }
        }
    }
    states: [
        State {
            name: "leftToRight"
            when: direction == 0
            AnchorChanges {
                target: clipper
                anchors.left: root.left
            }
        },
        State {
            name: "rightToLeft"
            when: direction == 1
            AnchorChanges {
                target: clipper
                anchors.right: root.right
            }
            AnchorChanges {
                target: image
                anchors.right: clipper.right
            }
        },
        State {
            name: "topToBottom"
            when: direction == 2
            AnchorChanges {
                target: clipper
                anchors.top: root.top
            }
        },
        State {
            name: "bottomToTop"
            when: direction == 3
            AnchorChanges {
                target: clipper
                anchors.bottom: root.bottom
            }
            AnchorChanges {
                target: image
                anchors.bottom: clipper.bottom
            }
        }
    ]
}

