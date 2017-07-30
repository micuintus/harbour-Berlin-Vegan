import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    id: header

    property var title
    property string text
    property var icon

    width: parent.width - 2*BVApp.Theme.paddingLarge
    height: txt.height + 2*BVApp.Theme.paddingLarge

    anchors {
        left: parent.left
        margins: BVApp.Theme.paddingLarge
    }

    Icon {
        id: iconItem
        icon: header.icon.iconString
        color: BVApp.Theme.highlightDimmerColor

        Component.onCompleted: {
            iconItem.textItem.font.family = header.icon.fontFamily
        }

        anchors {
            left: header.left
            verticalCenter: header.verticalCenter
        }
    }

    AppText {
        id: txt
        text: header.text
        color: BVApp.Theme.highlightDimmerColor

        anchors {
            left: header.left
            leftMargin: 2*BVApp.Theme.paddingLarge
            verticalCenter: header.verticalCenter
        }
    }
}
