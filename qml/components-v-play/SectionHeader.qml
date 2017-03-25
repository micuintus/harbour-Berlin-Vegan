import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    id: header

    property var title
    property string text

    width: parent.width
    height: txt.height

    AppText {
        id: txt
        text: header.text
        color: BVApp.Theme.highlightDimmerColor

        anchors.right: parent.right
        anchors.margins: BVApp.Theme.paddingLarge
    }
}
