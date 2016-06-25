import QtQuick 2.2
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

    Behavior on height { NumberAnimation { easing.type:  Easing.OutBack } }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: {
            parent.collapsed = !parent.collapsed
        }
    }
}

