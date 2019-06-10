import QtQuick 2.5

import Sailfish.Silica 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {
    id: tag
    property alias text: label.text
    radius: 25

    width: label.width + BVApp.Theme.paddingLarge
    height: label.height + BVApp.Theme.paddingSmall

    Label {
        anchors.centerIn: tag
        id: label
        color: "white"
        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
    }
}
