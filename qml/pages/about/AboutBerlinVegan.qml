/**
 *
 *  This file is part of the Berlin-Vegan guide (SailfishOS app version),
 *  Copyright 2015-2016 (c) by micu <micuintus.de> (micuintus@gmx.de).
 *
 *      <https://github.com/micuintus/harbour-Berlin-vegan>.
 *
 *  The Berlin-Vegan guide is Free Software:
 *  you can redistribute it and/or modify it under the terms of the
 *  GNU General Public License as published by the Free Software Foundation,
 *  either version 2 of the License, or (at your option) any later version.
 *
 *  Berlin-Vegan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with The Berlin Vegan Guide.
 *
 *  If not, see <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.
 *
**/

import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    id: page

    SilicaFlickable {

        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column
            width: page.width

            PageHeader {
                id: pageHeader
                title: qsTr("About")
            }

            Image  {
                id: logo
                source: "BerlinVegan.svg"
                sourceSize.width: page.width / 3.2
                sourceSize.height: page.width / 3.2
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingSmall
            }

            Label {
                id: underLogoText
                text: qsTr("Berlin-Vegan")
                font.pixelSize: Theme.fontSizeLarge

                color: Theme.highlightColor

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Label {
                id: copyright
                text: "Copyright \u00A9 2016 by micu &lt;<a href=\"micupage\">micuintus.de</a>\>"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                textFormat: Text.StyledText
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                onLinkActivated: Qt.openUrlExternally("http://www.micuintus.de/")
                linkColor: Theme.highlightColor

            }

            Item {
                width: parent.width
                height: Theme.paddingLarge * 2
            }

            Label {
                id: freeSoftwareBla
                text: qsTr("The Berlin-Vegan guide (SailfishOS app) is Free Software (FOSS): \
you can redistribute it and/or modify it under the terms of the
<a href=\"GPL\">GNU General Public License</a> as published by the Free Software Foundation, \
either version 2 of the license, or (at your option) any later version.")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                linkColor: Theme.highlightColor
                onLinkActivated:  pageStack.push(Qt.resolvedUrl("LicenseViewer.qml"),
                                                 {
                                                     "licenseFile": "LICENSE",
                                                     "licenseName": "GPLv2"
                                                 })
            }


            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Button {
                id: gplButton
                text: qsTr("View GPLv2")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl("LicenseViewer.qml"),
                                          {
                                              "licenseFile": "LICENSE",
                                              "licenseName": "GPLv2+"
                                          })
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                id: sourceCodeInfo
                text: qsTr("You can view the source code here:")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

            }

            Item {
                width: parent.width
                height: Theme.paddingSmall
            }

            Label {
                id: gitHubURL
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                textFormat: Text.StyledText

                text: "<a href=\"githubwebsite\">https://github.com/micuintus/harbour-Berlin-Vegan</a>"
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally("https://github.com/micuintus/harbour-Berlin-Vegan")
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge * 1.3
            }

            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: Theme.secondaryHighlightColor
                height: 2

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge * 1.3
            }

            Label {
                text: qsTr("Many thanks goes to the <a href=\"berlinvegan\">editorial team of berlin-vegan.de</a> \
for creating and maintaining the Berlin-Vegan project with its marvelous restaurant database, which this app uses. \
This content is released under the terms of the Attribution-NonCommercial 4.0 International Creative Commons license (CC BY-NC 4.0).")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally("http://www.berlin-vegan.de/team/kontakt/")
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Button {
                text: qsTr("View CC BY-NC")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked: pageStack.push(Qt.resolvedUrl("LicenseViewer.qml"),
                                          {
                                              "licenseFile": "CC-by-nc-legalcode.txt",
                                              "licenseName": "CC BY-NC"
                                          })
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge * 1.3
            }

            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: Theme.secondaryHighlightColor
                height: 2

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge * 1.3
            }


            Label {
                text: qsTr("Apart from Qt and other wonderful FOSS components of jolla's SailfishOS SDK, this application
greatfully makes use of the following third party Free Software projects:")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }


            ThirdPartySoftware {

               model: ListModel {
                    ListElement {
                        name: "Cutehacks Gel"
                        url: "https://github.com/Cutehacks/gel/"
                        licenseName: "MIT"
                        licenseFile: "LICENSE.Cutehacks"
                    }

                    ListElement {
                        name: "qml-utils"
                        url: "https://github.com/kromain/qml-utils"
                        licenseName: "MIT"
                        licenseFile: "LICENSE.qml-utils"
                    }

                    ListElement {
                        name: "YTPlayer"
                        url: "https://github.com/tworaz/sailfish-ytplayer"
                        licenseName: "3-clause BSD license (\"Modified BSD License\")"
                        licenseFile: "LICENSE.YTPlayer"
                    }

                    ListElement {
                        name: "Berlin-Vegan (Android app)"
                        url: "https://github.com/Berlin-Vegan/berlin-vegan-guide"
                        licenseName: "GPLv2"
                        licenseFile: "LICENSE"
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
