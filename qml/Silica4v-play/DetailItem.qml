import QtQuick 2.7
import VPlayApps 1.0

import Sailfish.Silica 1.0

import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    property alias label: keyText.text
    property int leftMargin
    property int rightMargin
    property alias value: valueText.text

    width: parent.width
    height: valueText.height

    Label {
        id: keyText
        color: BVApp.Theme.primaryColor

        font.pixelSize: BVApp.Theme.fontSizeExtraSmall

        anchors.left: parent.left
        anchors.right: valueText.left

                          // padding to the left edge
        anchors.leftMargin: BVApp.Theme.horizontalPageMargin
                         // + SectionHeader icon
                            + BVApp.Theme.fontSizeSmall
                         // + Distance between icon and text
                            + BVApp.Theme.paddingMedium
        anchors.rightMargin: BVApp.Theme.paddingSmall

        truncationMode: TruncationMode.Fade
    }

    Label {
        id: valueText
        color: BVApp.Theme.secondaryColor

        font.pixelSize: BVApp.Theme.fontSizeExtraSmall

        anchors {
            right: parent.right
            rightMargin: BVApp.Theme.horizontalPageMargin
        }

        horizontalAlignment: AppText.AlignRight

        truncationMode: TruncationMode.Fade
    }

}
