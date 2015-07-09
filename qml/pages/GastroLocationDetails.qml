import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property var restaurant

    onRestaurantChanged: console.log(restaurant.tags[0])

//    Column {
//        anchors.fill: parent

        Image {
            id: image
            source: restaurant.pictures[0].url
            fillMode: Image.PreserveAspectCrop
            height: page.height/3 // - flicka.contentY
            opacity: 1 - flicka.contentY / (page.height/3)
        }


        PageHeader {
            id: myheader
            title : restaurant.name
            y: 100 - flicka.contentY *0.3
            opacity: 1 - flicka.contentY / (page.height/3)

        }

        SilicaFlickable {
            id: flicka
            anchors {
                left: page.left
                right: page.right
                bottom: page.bottom
                top: image.bottom
            }

            contentHeight: myheader.height + dalabel.height
//            y: image.height

            Label {
        //        y: image.height
                id: dalabel
                font.pixelSize: Theme.fontSizeSmall
                text: restaurant.comment
                wrapMode: Text.WordWrap

                anchors {
                    // top: flicka.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }
//        }

    VerticalScrollDecorator {}
    }
}

