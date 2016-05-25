import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {

    id: page
    property var restaurant

    anchors.fill: parent

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

     IconToolBar {
         id: icontoolbar
         restaurant: page.restaurant
         anchors {
             left: page.left
             right: page.right
             top: image.bottom
             margins: Theme.paddingLarge
         }
         opacity: 1 - flicka.contentY / (page.height/3)


     }

     SilicaFlickable {
         id: flicka
         anchors {
             left: page.left
             right: page.right
             bottom: page.bottom
             top: icontoolbar.bottom
             margins: Theme.paddingLarge
         }

         contentHeight: myheader.height + dalabel.height

         Label {

             id: dalabel
             font.pixelSize: Theme.fontSizeSmall
             text: restaurant.comment
             wrapMode: Text.WordWrap

             anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
             }
         }

         VerticalScrollDecorator {}
    }
}

