import QtQuick 2.7
import QtQuick.Layouts 1.1
import VPlayApps 1.0
import "." as BVApp

IconButton {

    id: iconButton

    property string type
    property string icon
    property string color
    property real scale
    property real size

    icon: BVApp.Theme.iconBy(type)
    // dp(22) = 29 on 1334 x 750 (iPhone 6/6S)
    size: scale ? dp(22) * scale : dp(22)

    AppText {
        id: icn
        width: parent.width

        text: icon
        color: iconButton.color ? iconButton.color : BVApp.Theme.highlightDimmerColor

        font.family: "Material Icons"
        font.pixelSize: size
    }

    Component.onCompleted: {
        if (Layout.alignment) {
            icn.horizontalAlignment = Layout.alignment
        }
    }
}
