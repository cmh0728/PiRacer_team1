import QtQuick 2.15

Item {
    id: controller
    focus: true
    Keys.onPressed: (event) => {
        switch (event.key) {
        case Qt.Key_P:
            gearState.currentGear = "P"; break;
        case Qt.Key_R:
            gearState.currentGear = "R"; break;
        case Qt.Key_N:
            gearState.currentGear = "N"; break;
        case Qt.Key_D:
            gearState.currentGear = "D"; break;
        }
    }
    property QtObject gearState
}
