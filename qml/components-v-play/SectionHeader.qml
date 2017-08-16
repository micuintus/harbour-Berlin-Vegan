import QtQuick 2.7
import VPlayApps 1.0

import BerlinVegan.components.platform 1.0 as BVApp
import Sailfish.Silica 1.0

Item {

    id: header

    property var title
    property string text
    property var icon

    width: parent.width

    // The text item is anchored to the headers top with a
    // padding of the txt.height. Then we anchor the vertical center of the icon
    // to the text item's vertical center (top/bottom alignment of
    // V-Play's icon class seems to be broken).
    // As we want to have a small padding at the bottom,
    // we add BVApp.Theme.paddingSmall the height, as well -->
    height: txt.height * 2 + BVApp.Theme.paddingSmall

    Icon {
        id: iconItem
        icon: header.icon.iconString
        color: BVApp.Theme.highlightColor

        Component.onCompleted: {
            iconItem.textItem.font.family = header.icon.fontFamily
        }

        size:   BVApp.Theme.fontSizeSmall
        height: BVApp.Theme.fontSizeSmall
        width:  BVApp.Theme.fontSizeSmall

        anchors {
            left: header.left
            verticalCenter: txt.verticalCenter

            leftMargin: BVApp.Theme.horizontalPageMargin
        }
    }

    Label {
        id: txt
        text: header.text
        color: BVApp.Theme.highlightColor
        font.pixelSize:  BVApp.Theme.fontSizeSmall

        anchors {
            left: iconItem.right
            top: header.top

            leftMargin:  BVApp.Theme.paddingMedium
            topMargin:   txt.height
        }
    }
}
