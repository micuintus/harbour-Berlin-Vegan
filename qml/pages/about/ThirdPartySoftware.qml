import QtQuick 2.2
import Sailfish.Silica 1.0

SilicaListView {

    width: parent.width
    height: contentItem.childrenRect.height

    delegate: ListItem {

        width: parent.width
        height: contentItem.childrenRect.height

        Column {
            width: parent.width

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryColor
                text: model.name
            }

            Item {
                width: parent.width
                height: Theme.paddingMedium
            }

            Label {
               anchors {
                   horizontalCenter: parent.horizontalCenter
               }

               font.pixelSize: Theme.fontSizeExtraSmall
               color: Theme.secondaryColor
               textFormat: Text.StyledText

               text: "<a href=\"URL\">" + model.url + "</a>"
               linkColor: Theme.highlightColor
               onLinkActivated: Qt.openUrlExternally(model.url)
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Button {
                id: gplButton
                text: qsTr("View license")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl("LicenseViewer.qml"),
                                          {
                                              "licenseFile": model.licenseFile,
                                              "licenseName": model.licenseName
                                          })
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Separator {
                id: lastSeperator
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: Theme.secondaryHighlightColor
                height: 2

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
