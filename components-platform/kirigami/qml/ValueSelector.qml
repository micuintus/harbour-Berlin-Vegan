import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property string label
    property string labelUnitSingular
    property string labelUnitPlural
    property real from: 0
    property real to: 100
    property real stepSize: 1
    property real value: 0

    signal valueModified()

    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true
        Controls.Label {
            text: root.label + " " + Math.round(root.value) + " "
                  + (Math.round(root.value) === 1 ? root.labelUnitSingular : root.labelUnitPlural)
        }
    }

    Controls.Slider {
        Layout.fillWidth: true
        from: root.from
        to: root.to
        stepSize: root.stepSize
        value: root.value
        onMoved: {
            root.value = value
            root.valueModified()
        }
    }
}
