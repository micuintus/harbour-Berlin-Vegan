import QtQuick
import org.kde.kirigami as Kirigami
import BerlinVegan.components.platform 1.0 as BVApp

MouseArea {
    id: iconButton

    property string type
    property color color: BVApp.Theme.highlightColor
    property real iconScale: 1
    property alias verticalAlignment: icon.verticalAlignment
    property alias text: subtitle.text

    height: col.height
    width: icon.implicitWidth

    Column {
        id: col
        width: parent.width

        Kirigami.Icon {
            id: icon
            property int verticalAlignment: Text.AlignVCenter
            source: BVApp.Theme.iconFor(type).iconString
            color: iconButton.enabled ? iconButton.color : BVApp.Theme.disabledColor
            isMask: true
            width: BVApp.Theme.iconSizeLarge * iconButton.iconScale
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: subtitle
            width: parent.width
            height: text ? implicitHeight : 0
            font.pixelSize: BVApp.Theme.fontSizeTiny
            font.bold: true
            color: icon.color
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
