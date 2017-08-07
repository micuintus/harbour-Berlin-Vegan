import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    property var label
    property var leftMargin
    property var rightMargin
    property var value

    width: parent.width - 2*BVApp.Theme.paddingLarge
    height: valueText.height

    anchors {
        left: parent.left
        margins: BVApp.Theme.paddingLarge
    }

    Label {
        id: keyText
        text: label
        color: BVApp.Theme.primaryColor

        anchors.left: parent.left
        anchors.right: valueText.left

        anchors.leftMargin: 2*BVApp.Theme.paddingLarge
        anchors.rightMargin: BVApp.Theme.paddingSmall

        truncationMode: TruncationMode.Fade
    }

    Label {
        id: valueText
        text: value
        color: BVApp.Theme.secondaryColor

        anchors.right: parent.right
        horizontalAlignment: AppText.AlignRight

        truncationMode: TruncationMode.Fade

    }

}
