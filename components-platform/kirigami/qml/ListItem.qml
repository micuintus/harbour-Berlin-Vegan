import QtQuick
import org.kde.kirigami as Kirigami

// Simple row wrapper — matches Felgo's SimpleRow API.
// Uses MouseArea (not ItemDelegate) so children anchor directly
// to the row without contentItem indirection.
MouseArea {
    id: listItem

    property var contentWidth
    property var contentHeight
    property bool highlighted: listItem.pressed

    height: contentHeight || implicitHeight
    width: parent ? parent.width : 0

    // Divider at bottom
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Kirigami.Theme.separatorColor || "#B6B6B6"
    }

    // Press highlight
    Rectangle {
        anchors.fill: parent
        color: listItem.pressed ? (Kirigami.Theme.highlightColor || "#97BF0F") : "transparent"
        opacity: 0.1
    }
}
