import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: gears
    width: 215
    height: 80

    property QtObject gearState

    Text {
        id: p
        x: 0
        y: gearState.currentGear === "P" ? 0 : 25
        width: 18
        height: 80
        text: "P"
        color: gearState.currentGear === "P" ? "#ffffff" : "#595f66"
        font.pixelSize: gearState.currentGear === "P" ? 80 : 30
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        font.family: "Slate For FCA " + (gearState.currentGear === "P" ? "Regular" : "Book")
    }

    Text {
        id: r
        x: 53
        y: gearState.currentGear === "R" ? 0 : 25
        width: 18
        height: 80
        text: "R"
        color: gearState.currentGear === "R" ? "#ffffff" : "#595f66"
        font.pixelSize: gearState.currentGear === "R" ? 80 : 30
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        font.family: "Slate For FCA " + (gearState.currentGear === "R" ? "Regular" : "Book")
    }

    Text {
        id: n
        x: 106
        y: gearState.currentGear === "N" ? 0 : 25
        width: 18
        height: 80
        text: "N"
        color: gearState.currentGear === "N" ? "#ffffff" : "#595f66"
        font.pixelSize: gearState.currentGear === "N" ? 80 : 30
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        font.family: "Slate For FCA " + (gearState.currentGear === "N" ? "Regular" : "Book")
    }

    Text {
        id: d
        x: 163
        y: gearState.currentGear === "D" ? 0 : 25
        width: 18
        height: 80
        text: "D"
        color: gearState.currentGear === "D" ? "#ffffff" : "#595f66"
        font.pixelSize: gearState.currentGear === "D" ? 80 : 30
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        font.family: "Slate For FCA " + (gearState.currentGear === "D" ? "Regular" : "Book")
    }
}
