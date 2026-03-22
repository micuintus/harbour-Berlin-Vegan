import QtQuick 2.7
import QtQuick.Layouts 1.1
import Felgo
import "." as BVApp

MouseArea {

    id: iconButton

    property string type
    property string color
    property real iconScale: 1
    property alias verticalAlignment: icn.verticalAlignment
    property alias text: subtitle.text

    height: column.height
    width: icn.implicitWidth

    Column {

        id: column
        width: parent.width

        spacing: text ? BVApp.Theme.iconToolBarPadding : 0

        AppText {
            id: icn
            width: parent.width

            text: BVApp.Theme.iconFor(type).iconString

            color: iconButton.enabled ? (iconButton.color ? iconButton.color : BVApp.Theme.highlightColor)
                                      : BVApp.Theme.disabledColor;
            font.family: BVApp.Theme.iconFor(type).fontFamily

            font.pixelSize: BVApp.Theme.iconSizeLarge * iconButton.iconScale
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
        }


        AppText {
            id: subtitle
            width: parent.width
            height: text ? implicitHeight : 0

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
