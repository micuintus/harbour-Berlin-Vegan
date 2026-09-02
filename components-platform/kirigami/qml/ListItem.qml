import QtQuick
import org.kde.kirigami as Kirigami

// Simple row wrapper — matches Felgo's SimpleRow API.
// Uses Item root so children anchor directly (no contentItem indirection).
// Custom clicked(int) signal passes the ListView delegate index.
Item {
    id: listItem

    signal clicked(int index)

    property var contentWidth
    property var contentHeight
    property bool highlighted: mouseArea.pressed
    property bool dividerVisible: true

    height: contentHeight || implicitHeight
    width: parent ? parent.width : 0

    // Press highlight
    Rectangle {
        anchors.fill: parent
        color: mouseArea.pressed ? (Kirigami.Theme.highlightColor || "#97BF0F") : "transparent"
        opacity: 0.1
        z: -1
    }

    // Divider at bottom
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        visible: listItem.dividerVisible
        color: "#BDC3C7"
        z: -1
    }

    // Click handler — passes delegate index to signal
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        z: -2
        onClicked: listItem.clicked(typeof model !== "undefined" ? model.index : -1)
    }
}
