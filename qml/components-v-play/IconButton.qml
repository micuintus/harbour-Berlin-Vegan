import QtQuick 2.7
import QtQuick.Layouts 1.1
import VPlayApps 1.0
import "." as BVApp

MouseArea {

    id: iconButton

    property string type
    property string color
    property real iconScale: 1
    property alias verticalAlignment: icn.verticalAlignment
    property alias text: subtitle.text

    height: text ? icn.height + subtitle.height + 7 : icn.height
    width: Math.max(icn.implicitWidth)

    Column {

        width: parent.width

        spacing: text ? 7 : 0

        AppText {
            id: icn
            width: parent.width

            text: BVApp.Theme.iconFor(type).iconString

            color: iconButton.enabled ? (iconButton.color ? iconButton.color : BVApp.Theme.highlightColor)
                                      : BVApp.Theme.secondaryColor;
            font.family: BVApp.Theme.iconFor(type).fontFamily

            font.pixelSize: BVApp.Theme.iconSizeLarge * iconButton.iconScale
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
            verticalAlignment:  Text.AlignVCenter
        }
    }
}
