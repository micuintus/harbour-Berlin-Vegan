import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0
import QtQuick.Layouts 1.1

Page {
    id: page
    property var restaurant

    onRestaurantChanged: console.log(restaurant.tags[0])

    DBusInterface {
        id: voicecall

        destination: "com.jolla.voicecall.ui"
        path: "/"
        iface: "com.jolla.voicecall.ui"

        function dial(number) {
            call('dial', number)
        }
    }

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

        RowLayout {
            id: row
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Layout.maximumWidth: page.width/3

            width: page.width
            anchors {
                left: page.left
                right: page.right
                top: image.bottom
                margins: Theme.paddingLarge
            }

            opacity: 1 - flicka.contentY / (page.height/3)

            IconButton {
                icon.source: "image://theme/icon-l-answer?" + (pressed
                             ? Theme.highlightColor
                             : Theme.primaryColor)
                icon.scale: Theme.iconSizeMedium / Theme.iconSizeLarge

                onClicked: voicecall.dial(01722836020)
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            IconButton {
                icon.source: "image://theme/icon-m-favorite?" + (pressed
                             ? Theme.highlightColor
                             : Theme.primaryColor)
                onClicked: console.log("Play clicked!")
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }


            IconButton {
                icon.source: "image://theme/icon-m-home?" + (pressed
                             ? Theme.highlightColor
                             : Theme.primaryColor)

                onClicked: console.log("Play clicked!")
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

        }

        SilicaFlickable {
            id: flicka
            anchors {
                left: page.left
                right: page.right
                bottom: page.bottom
                top: row.bottom
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

