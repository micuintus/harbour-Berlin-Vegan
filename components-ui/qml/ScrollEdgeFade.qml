import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

// Dissolves a flickable's content into the chrome above and below it, instead
// of letting it end on a hard line under a search field or over a tab bar.
//
// A gradient scrim rather than an OpacityMask: the ramp effect is Silica's own
// type on Sailfish and gains no second edge without custom work there, and the
// list background is opaque anyway, so a scrim is indistinguishable and free.
Item {
    id: root

    property Flickable flickable
    property color edgeColor: BrandTokens.surface
    property real extent: BVApp.Theme.gridUnit * 1.5

    // Each edge only appears once there is something to scroll past it, so a
    // list that fits shows no decoration at all.
    readonly property real topStrength:
        flickable ? Math.min(1, Math.max(0, flickable.contentY) / extent) : 0
    readonly property real bottomStrength: {
        if (!flickable)
            return 0
        const remaining = flickable.contentHeight - flickable.contentY - flickable.height
        return Math.min(1, Math.max(0, remaining) / extent)
    }

    anchors.fill: flickable
    visible: flickable !== null

    Rectangle {
        width: parent.width
        height: root.extent
        anchors.top: parent.top
        opacity: root.topStrength
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.edgeColor }
            GradientStop { position: 1.0; color: "transparent" }
        }
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Rectangle {
        width: parent.width
        height: root.extent
        anchors.bottom: parent.bottom
        opacity: root.bottomStrength
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: root.edgeColor }
        }
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }
}
