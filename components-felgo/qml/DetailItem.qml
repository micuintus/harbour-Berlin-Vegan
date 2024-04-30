import QtQuick 2.7
import Felgo

import Sailfish.Silica 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Item {
    id: me
    property alias label: labelText.text
    property alias value: valueText.text
    property alias fontWeight: labelText.font.weight
    property alias fontSize: labelText.font.pixelSize
    readonly property real leftMargin: labelText.anchors.leftMargin
    readonly property real rightMargin: valueText.anchors.rightMargin
    property alias labelColor: labelText.color
    property alias valueColor: valueText.color

    width: parent.width
    height: valueText.height

    Label {
        id: labelText

        color: BVApp.Theme.primaryColor
        font.pixelSize: BVApp.Theme.fontSizeExtraSmall

        anchors.left: parent.left
        anchors.right: valueText.left

                          // padding to the left edge
        anchors.leftMargin: BVApp.Theme.horizontalPageMargin + BVApp.Theme.sectionHeaderIconLeftPadding
                         // + SectionHeader icon
                            + BVApp.Theme.fontSizeSmall * 1.05
                         // + Distance between icon and text
                            + BVApp.Theme.sectionHeaderIconTextPadding
        anchors.rightMargin: BVApp.Theme.paddingSmall

        truncationMode: TruncationMode.Fade
    }

    Label {
        id: valueText
        color: BVApp.Theme.secondaryColor

        font {
            pixelSize: BVApp.Theme.fontSizeExtraSmall
            weight: labelText.font.weight
        }

        anchors {
            right: parent.right
            rightMargin: BVApp.Theme.horizontalPageMargin
        }

        horizontalAlignment: AppText.AlignRight

        truncationMode: TruncationMode.Fade
    }

}
