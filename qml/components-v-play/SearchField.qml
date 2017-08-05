import QtQuick 2.7
import VPlayApps 1.0

import BerlinVegan.components.platform 1.0 as BVApp

SearchBar {

    keepVisible: true
    iosAlternateStyle: true

    // this integrates better on iOS with the overall background color
    barBackgroundColor: "white"

                           //% "Search..."
    placeHolderText: qsTrId("id-search")

    property Item flickableForSailfish

    Rectangle {
        id: divider

        width: parent.width
        height: BVApp.Theme.dividerHeight
        color: BVApp.Theme.dividerColor
        // HACK: the divider here is stronger than the divider in the venue list. until we don't know why, we go with this workaround.
        opacity: 0.5

        anchors.bottom: parent.bottom
        anchors.left: parent.left
    }
}
