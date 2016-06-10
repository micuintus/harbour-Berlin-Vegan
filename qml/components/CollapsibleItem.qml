import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property bool collapsed: true
    property var expandItem
    property real collapsedHeight
    property real expandedHeight

    clip: true

    height: collapsed
          ? collapsedHeight
          : expandedHeight

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: {
            parent.collapsed = !parent.collapsed
        }
    }
}

