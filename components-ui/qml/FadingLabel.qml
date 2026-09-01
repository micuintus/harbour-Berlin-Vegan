import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

// A label whose overflow dissolves instead of being cut.
//
// The platform Label's Fade truncation only clips on Felgo, so long text ends
// on a hard vertical edge.
//
// The dissolve is a gradient scrim, not an OpacityMask: one mask per label put
// hundreds of ShaderEffectSources into a scrolling list, and against an opaque
// background a scrim is indistinguishable. Callers whose background is not
// `surface` must say so via fadeColor.
Item {
    id: root

    property alias text: label.text
    property alias color: label.color
    property alias font: label.font
    property alias horizontalAlignment: label.horizontalAlignment
    property alias verticalAlignment: label.verticalAlignment

    // Colour the text dissolves into: whatever sits behind it.
    property color fadeColor: BrandTokens.surface
    // Width of the dissolve, as a fraction of the item.
    property real fadeFraction: 0.22

    readonly property bool overflowing: label.contentWidth > width + 0.5

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    baselineOffset: label.baselineOffset
    clip: true

    BVApp.Label {
        id: label
        width: root.width
        height: root.height
    }

    Rectangle {
        anchors.right: parent.right
        width: Math.round(parent.width * root.fadeFraction)
        height: parent.height
        visible: root.overflowing
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: root.fadeColor }
        }
    }
}
