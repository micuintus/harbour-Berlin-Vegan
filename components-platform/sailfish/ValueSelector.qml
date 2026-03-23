import Sailfish.Silica 1.0
import QtQuick 2.6

Column {
    width: parent.width

    property string labelUnitSingular
    property string labelUnitPlural

    property alias label: label.text

    property alias from: slider.minimumValue
    property alias to: slider.maximumValue
    property alias stepSize: slider.stepSize
    property alias value: slider.value

    signal valueModified

    Label {
        id: label

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.rightMargin: Theme.horizontalPageMargin
    }

    Slider {
        id: slider
        width: parent.width

        on_ValueLabelChanged: {
            _valueLabel.font.pixelSize = Theme.fontSizeExtraLarge
            _valueLabel.anchors.bottomMargin = Theme.paddingLarge
        }

        onValueChanged: valueModified(value)

        valueText: value
                   + " "
                   + (value ===  1 ? labelUnitSingular
                                   : labelUnitPlural)
    }
}
