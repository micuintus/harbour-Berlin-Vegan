import QtQuick 2.7
import Felgo 3.0
import BerlinVegan.components.platform 1.0 as BVApp

Column {
    id: valueSelector

    property alias label: label.text
    property string labelUnitSingular
    property string labelUnitPlural
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    property alias value: slider.value

    signal valueModified

    anchors.left: parent.left
    anchors.right: parent.right

    anchors.leftMargin: BVApp.Theme.horizontalPageMargin
                        + BVApp.Theme.sectionHeaderIconLeftPadding
                        + BVApp.Theme.fontSizeSmall * 1.05
                        + BVApp.Theme.sectionHeaderIconTextPadding

    anchors.rightMargin: BVApp.Theme.horizontalPageMargin

    Item {
        height: BVApp.Theme.paddingSmall
        width: parent.width
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right

        height: label.height

        AppText {
            id: label

            anchors.left: parent.left
            font.pixelSize: BVApp.Theme.fontSizeSmall
        }

        AppText {
            id: valueDisp

            text: slider.value
                  + " "
                  + (slider.value ===  1 ? labelUnitSingular
                                         : labelUnitPlural)
            anchors.right: parent.right
            font.pixelSize: BVApp.Theme.fontSizeSmall
        }
    }

    Item {
        height: BVApp.Theme.paddingSmall
        width: parent.width
    }

    AppSlider {
        id: slider

        anchors.bottomMargin: BVApp.Theme.paddingSmall
        onMoved: valueSelector.valueModified(value)

        anchors.left: parent.left
        anchors.right: parent.right
    }

    Item {
        height: BVApp.Theme.paddingSmall
        width: parent.width
    }
}

