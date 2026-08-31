import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

// A label whose overflow dissolves instead of being cut.
//
// The platform Label's Fade truncation mode only clips on Felgo, so long text
// ends on a hard vertical edge. The ramp has to be a sibling of the text it
// masks: as a child it would feed a ShaderEffectSource from its own ancestor.
Item {
    id: root

    property alias text: label.text
    property alias color: label.color
    property alias font: label.font
    property alias horizontalAlignment: label.horizontalAlignment
    property alias verticalAlignment: label.verticalAlignment
    property alias baselineOffsetProxy: label.baselineOffset

    // Where the dissolve starts, as a fraction of the width.
    property real fadeStart: 0.78

    readonly property bool overflowing: label.contentWidth > width + 0.5

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    baselineOffset: label.baselineOffset

    BVApp.Label {
        id: label
        width: root.width
        height: root.height
        clip: true
    }

    BVApp.OpacityRampEffect {
        anchors.fill: parent
        sourceItem: label
        direction: BVApp.Theme.opacityRampLeftToRight
        enabled: root.overflowing
        offset: root.fadeStart
        slope: 1.0
    }
}
