import QtQuick 2.7
import VPlayApps 1.0

import Sailfish.Silica 1.0

import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    property var label
    property var leftMargin
    property var rightMargin
    property var value

    width: parent.width
    height: valueText.height

    Label {
        id: keyText
        text: label
        color: BVApp.Theme.primaryColor

        font.pixelSize: BVApp.Theme.fontSizeSmall

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
        text: value
        color: BVApp.Theme.secondaryColor

        font.pixelSize: BVApp.Theme.fontSizeSmall

        anchors {
            right: parent.right
            rightMargin: BVApp.Theme.horizontalPageMargin
        }

        horizontalAlignment: AppText.AlignRight

        truncationMode: TruncationMode.Fade
    }

}
