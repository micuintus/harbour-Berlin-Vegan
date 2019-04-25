import QtQuick 2.7
import Felgo 3.0

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
    // Felgo's icon class seems to be broken).
    // As we want to have a small padding at the bottom,
    // we add BVApp.Theme.paddingSmall the height, as well -->
    height: txt.height * 2 + BVApp.Theme.paddingSmall

    AppText {
        id: iconHeightMeasure
        text: header.icon.iconString
        font.family: header.icon.fontFamily
        font.pixelSize: BVApp.Theme.fontSizeSmall
        visible: false
    }

    AppText {
        id: iconItem

        color: BVApp.Theme.highlightColor

        text: header.icon.iconString
        font.family: header.icon.fontFamily
        font.pixelSize: BVApp.Theme.fontSizeSmall

        scale:  0.78 * (txt.height / iconHeightMeasure.height)
        transformOrigin: Item.Top

        anchors {
            left: header.left
            top: header.top

            leftMargin: BVApp.Theme.horizontalPageMargin + BVApp.Theme.sectionHeaderIconLeftPadding
            topMargin:  txt.height
        }
    }

    AppText {
        id: txt
        text: header.text
        color: BVApp.Theme.highlightColor
        font.pixelSize: BVApp.Theme.fontSizeSmall

        anchors {
            left: iconItem.right                                // account for height/width difference
                                                                // to fit the alignment with DetailItem
            leftMargin: BVApp.Theme.sectionHeaderIconTextPadding + iconItem.height - iconItem.width
            verticalCenter: iconItem.verticalCenter
        }
    }
}
