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

    AppText {
        id: keyText
        text: label
    }

    AppText {
        id: valueText
        text: value
        color: BVApp.Theme.secondaryColor

        anchors.right: parent.right
        horizontalAlignment: AppText.AlignRight
    }

}
