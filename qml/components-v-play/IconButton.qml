import QtQuick 2.7
import QtQuick.Layouts 1.1
import VPlayApps 1.0
import "." as BVApp

IconButton {

    id: iconButton

    property string type
    property string color
    property real scale
    property real size

    // dp(22) = 29 on 1334 x 750 (iPhone 6/6S)
    size: scale ? dp(22) * scale : dp(22)

    AppText {
        id: icn
        anchors.fill: parent

        text: BVApp.Theme.iconFor(type).iconString

        color: iconButton.color ? iconButton.color : BVApp.Theme.highlightColor
        font.family: BVApp.Theme.iconFor(type).fontFamily

        font.pixelSize: size
        horizontalAlignment: Text.AlignHCenter
    }

    Component.onCompleted: {
        // HACK: if we are not the IconToolBar, we are the VenueMapPage
        if (!Layout.alignment) {
            icn.verticalAlignment = Text.AlignBottom
        }
    }
}
