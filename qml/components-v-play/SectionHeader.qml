import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    id: header

    property var title
    property string text
    property var icon

    width: parent.width
    height: 1.7 * txt.height

    Icon {
        id: iconItem
        icon: header.icon.iconString
        color: BVApp.Theme.highlightDimmerColor

        Component.onCompleted: {
            iconItem.textItem.font.family = header.icon.fontFamily
        }

        anchors {
            left: header.left
            bottom: header.bottom
            margins: BVApp.Theme.paddingLarge
            bottomMargin: 0.25 * BVApp.Theme.paddingLarge
        }
    }

    AppText {
        id: txt
        text: header.text
        color: BVApp.Theme.highlightDimmerColor

        anchors {
            right: header.right
            bottom: header.bottom
            margins: BVApp.Theme.paddingLarge
            bottomMargin: 0.25 * BVApp.Theme.paddingLarge
        }
    }
}
