import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {

    id: page
    property var restaurant

    anchors.fill: parent

    SilicaFlickable {
        id: flicka
        anchors.fill: parent
        property real nonDescriptionHeaderHeight: image.initalHeight + icontoolbar.height
        contentHeight: nonDescriptionHeaderHeight + dalabel.height
        property real scrolledUpRatio: 1 - (contentY / nonDescriptionHeaderHeight)

        VerticalScrollDecorator {}

        Image {
            id: image

            source: restaurant.pictures[0].url
            property real initalHeight: page.height/3

            fillMode: Image.PreserveAspectCrop

            height: Math.max(initalHeight - flicka.contentY,0)
            y: flicka.contentY
            opacity: flicka.scrolledUpRatio
        }

        Rectangle {
            property int xMargin: 10
            property int yMargin: 7
            property real initialOpacity: 0.6
            x: myheader.extraContent.x + myheader.extraContent.width - xMargin
            y: myheader.y + myheader.childrenRect.y - yMargin - flicka.contentY * 0.1
            height: myheader.childrenRect.height + yMargin*2
            width: (myheader.childrenRect.width - myheader.extraContent.width) + xMargin*2
            radius: 5
            color: Theme.highlightDimmerColor
            opacity: initialOpacity  * flicka.scrolledUpRatio
        }

        PageHeader {
            id: myheader
            property int initalY: 100

            title : restaurant.name
            y: initalY  + flicka.contentY * 0.5
            opacity: flicka.scrolledUpRatio
        }

        IconToolBar {
            id: icontoolbar
            restaurant: page.restaurant

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            y: image.initalHeight + Theme.paddingLarge
            opacity: flicka.scrolledUpRatio
        }

        Label {
            id: dalabel
            font.pixelSize: Theme.fontSizeSmall
            text: restaurant.comment
            wrapMode: Text.WordWrap

            anchors {
                left: parent.left
                right: parent.right
                top: icontoolbar.bottom
                margins: Theme.paddingLarge
            }
        }
    }
}

