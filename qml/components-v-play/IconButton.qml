import QtQuick 2.7
import QtQuick.Layouts 1.1
import VPlayApps 1.0
import "." as BVApp

IconButton {

    id: iconButton

    property string type
    property string color
    property real iconScale
    property alias verticalAlignment: icn.verticalAlignment
    property alias text: subtitle.text

    Column {
        anchors.fill: parent

        spacing: 4

        AppText {
            id: icn

            width: parent.width

            text: BVApp.Theme.iconFor(type).iconString

            color: iconButton.enabled ? (iconButton.color ? iconButton.color : BVApp.Theme.highlightColor)
                                      : BVApp.Theme.secondaryColor;
            font.family: BVApp.Theme.iconFor(type).fontFamily

            font.pixelSize: iconButton.iconScale ? BVApp.Theme.iconSizeLarge * iconButton.iconScale : BVApp.Theme.iconSizeLarge
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
        }


        AppText {
            id: subtitle

            width: parent.width

            font.pixelSize: BVApp.Theme.fontSizeTiny
            font.bold: true
            font.letterSpacing: 1.2
            color: icn.color
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignBottom
        }
    }
}
