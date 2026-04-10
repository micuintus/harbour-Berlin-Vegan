import QtQuick.Controls as Controls

Controls.BusyIndicator {
    property real size: 0
    width: size > 0 ? size : implicitWidth
    height: size > 0 ? size : implicitHeight
}
