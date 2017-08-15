import QtQuick 2.7
import QtQuick.Layouts 1.1
import VPlayApps 1.0
import "." as BVApp

IconButton {

    id: iconButton

    property string type
    property string color
    property real scale
    property int verticalAlignment: Text.AlignVCenter


    AppText {
        id: icn
        anchors.fill: parent

        text: BVApp.Theme.iconFor(type).iconString

        color: iconButton.color ? iconButton.color : BVApp.Theme.highlightColor
        font.family: BVApp.Theme.iconFor(type).fontFamily

        font.pixelSize: iconButton.scale ? BVApp.Theme.iconSizeLarge * iconButton.scale : BVApp.Theme.iconSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: iconButton.verticalAlignment
    }

}
