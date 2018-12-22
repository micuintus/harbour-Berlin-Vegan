import QtQuick 2.7
import QtQuick.Layouts 1.1
import VPlayApps 1.0
import "." as BVApp

IconButton {

    id: iconButton

    property string type
    property string color
    property real scale
    property alias verticalAlignment: icn.verticalAlignment

    AppText {
        id: icn
        anchors.fill: parent

        text: BVApp.Theme.iconFor(type).iconString

        color: iconButton.enabled ? (iconButton.color ? iconButton.color : BVApp.Theme.highlightColor)
                                  : BVApp.Theme.secondaryColor;
        font.family: BVApp.Theme.iconFor(type).fontFamily

        font.pixelSize: iconButton.scale ? BVApp.Theme.iconSizeLarge * iconButton.scale : BVApp.Theme.iconSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:  Text.AlignVCenter
    }

}
