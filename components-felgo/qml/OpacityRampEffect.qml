import QtQuick
import Qt5Compat.GraphicalEffects

// Opacity gradient fade effect using OpacityMask.
// Direction: 0=LtR, 1=RtL, 2=TtB, 3=BtT
Item {
    id: root

    property Item sourceItem
    property bool enabled: true
    property int direction: 0
    property real offset: 0.5
    property real slope: 2.0

    anchors.fill: sourceItem ? sourceItem : parent
    visible: enabled && sourceItem && sourceItem.visible

    OpacityMask {
        anchors.fill: parent
        source: ShaderEffectSource {
            sourceItem: root.enabled ? root.sourceItem : null
            hideSource: root.enabled
        }
        maskSource: Rectangle {
            width: root.width
            height: root.height
            gradient: Gradient {
                orientation: (root.direction <= 1) ? Gradient.Horizontal : Gradient.Vertical
                GradientStop {
                    position: 0.0
                    color: root.direction === 1 || root.direction === 3 ? "transparent" : "#FFFFFFFF"
                }
                GradientStop {
                    position: Math.max(0, root.offset)
                    color: root.direction === 1 || root.direction === 3 ? "#FFFFFFFF" : "#FFFFFFFF"
                }
                GradientStop {
                    position: 1.0
                    color: root.direction === 1 || root.direction === 3 ? "#FFFFFFFF" : "transparent"
                }
            }
        }
        visible: root.enabled
    }
}
