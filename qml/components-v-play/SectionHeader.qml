import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    id: header

    property var title
    property string text
    property var icon


    width: parent.width
    height: txt.height

    Icon {
        id: iconItem
        icon: header.icon.iconString

        Component.onCompleted: {
            iconItem.textItem.font.family = header.icon.fontFamily
        }

        color: BVApp.Theme.highlightDimmerColor
        anchors.left: parent.left
        anchors.margins: BVApp.Theme.paddingLarge
    }

    AppText {
        id: txt
        text: header.text
        color: BVApp.Theme.highlightDimmerColor

        anchors.right: parent.right
        anchors.margins: BVApp.Theme.paddingLarge
    }
}
