import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    id: page

    anchors.top: parent.top
    width: parent.width

    PageHeader {
        id: pageHeader
        title: qsTr("About")
    }

    Image  {
        id: logo
        source: "BerlinVegan.svg"
        sourceSize.width: page.width / 3.5
        sourceSize.height: page.width / 3.5
        anchors {
            top: pageHeader.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingMedium
        }
    }

    Label {
        id: underLogoText
        text: qsTr("Berlin-Vegan")
        font.pixelSize: Theme.fontSizeLarge

        color: Theme.highlightColor

        anchors {
            top: logo.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingMedium
        }
    }

    Label {
        id: copyright
        text: "Copyright \u00A9 by micu <micuintus.de>"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        anchors {
            top: underLogoText.bottom
            horizontalCenter: parent.horizontalCenter
        }
    }

    Label {
        id: freeSoftwareBla
        text: qsTr("The Berlin-Vegan guide is Free Software: \
you can redistribute it and/or modify it under the terms of the \
<a href=\"http://kodkod\">GNU General Public License</a> as published by the Free Software Foundation, \
either version 2 of the license, or (at your option) any later version.")
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        textFormat: Text.StyledText
        anchors {
            top: copyright.bottom
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }

        onLinkActivated:  pageStack.push(Qt.resolvedUrl("LicenseViewer.qml"),
                                         {
                                         "licenseFile": "GPLv2"
                                         })
        linkColor: Theme.highlightColor


    }

    Button {
        text: qsTr("View GPLv2")
        anchors {
            top: freeSoftwareBla.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }

        onClicked: pageStack.push(Qt.resolvedUrl("LicenseViewer.qml"),
                                  {
                                  "licenseFile": "GPLv2"
                                  })
    }

    Label {
        id: gitHubURL
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingSmall
        }

        color: Theme.secondaryColor

        font.pixelSize: Theme.fontSizeTiny

        text: "https://github.com/micuintus/harbour-Berlin-Vegan"
   }
}
