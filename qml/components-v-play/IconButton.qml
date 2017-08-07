import QtQuick 2.7
import QtQuick.Layouts 1.1
import VPlayApps 1.0
import "." as BVApp

IconButton {

    id: iconButton

    property string type
    property string color
    property real scale


    AppText {
        id: icn
        anchors.fill: parent

        text: BVApp.Theme.iconFor(type).iconString

        color: iconButton.color ? iconButton.color : BVApp.Theme.highlightColor
        font.family: BVApp.Theme.iconFor(type).fontFamily

        font.pixelSize: scale ? BVApp.Theme.iconSizeLarge * scale : BVApp.Theme.iconSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   iconButton.Layout.alignment ?
                                 Text.AlignVCenter
                               : Text.AlignBottom
    }
}
