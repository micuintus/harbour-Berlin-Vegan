import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property var restaurant

     SilicaFlickable {
         id: flicka
         anchors.fill: parent
         contentHeight: column.height

        Column {
            id: column

            // width: page.width
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: myheader
                title : restaurant.name
                height: 100 - flicka.contentY*5
            }
            Label {
                font.pixelSize: Theme.fontSizeSmall
                text: restaurant.comment
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }
        }
        VerticalScrollDecorator {}

    }

}
