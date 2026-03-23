import QtQuick 2.5
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {
    id: tag
    property alias text: label.text
    radius: 25

    width: label.width + BVApp.Theme.paddingLarge
    height: label.height + BVApp.Theme.paddingSmall

    BVApp.Label {
        id: label
        anchors.centerIn: tag
        color: "white"
        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
    }
}
