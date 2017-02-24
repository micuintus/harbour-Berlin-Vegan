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
import BerlinVegan.components 1.0 as BVApp

BVApp.Page {

    id: page

    SilicaFlickable {

        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column
            width: page.width

            PageHeader {
                id: pageHeader
                             //% "About"
                title: qsTrId("id-about-page-title")
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
                height: BVApp.Theme.paddingMedium
            }

            Label {
                id: underLogoText
                            //% "Berlin-Vegan"
                text: qsTrId("id-berlin-vegan")
                font.pixelSize: BVApp.Theme.fontSizeLarge

                color: BVApp.Theme.highlightColor

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }


            Item {
                width: parent.width
                height: BVApp.Theme.paddingMedium
            }

            Label {
                text: "Copyright \u00A9 2016 by micu"
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.highlightColor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Label {
                text: "&lt;<a href=\"micupage\">micuintus.de</a>\>"
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.highlightColor
                textFormat: Text.StyledText
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                onLinkActivated: Qt.openUrlExternally("http://www.micuintus.de/")
                linkColor: BVApp.Theme.highlightColor

            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingMedium
            }
            Label {
                            //% "Version"
                text: qsTrId("id-version") + ": " + Qt.application.version
                font.pixelSize: BVApp.Theme.fontSizeSmall

                color: BVApp.Theme.secondaryColor

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge * 2
            }

            Label {
                id: freeSoftwareBla
                //% "The Berlin-Vegan guide (SailfishOS app) is Free Software (FOSS): "
                //% "you can redistribute it and/or modify it under the terms of the "
                //% "<a href=\"GPL\">GNU General Public License</a> as published by the "
                //% "Free Software Foundation, either version 2 of the license, or "
                //% "(at your option) any later version."
                text: qsTrId("id-bvapp-is-free-software")
                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: BVApp.Theme.paddingLarge
                }

                linkColor: BVApp.Theme.highlightColor
                onLinkActivated:  pageStack.push(Qt.resolvedUrl("LicenseViewer.qml"),
                                                 {
                                                     "licenseFile": "LICENSE",
                                                     "licenseName": "GPLv2"
                                                 })
            }


            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge
            }

            Button {
                id: gplButton
                //% "View GPLv2"
                text: qsTrId("id-view-gplv2")
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
                height: BVApp.Theme.paddingLarge
            }

            Label {
                id: sourceCodeInfo
                            //% "You can view the source code here:"
                text: qsTrId("id-you-can-view-source-code-here")
                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingSmall
            }

            Label {
                id: gitHubURL
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                color: BVApp.Theme.secondaryColor
                textFormat: Text.StyledText

                text: "<a href=\"githubwebsite\">https://github.com/micuintus/harbour-Berlin-Vegan</a>"
                linkColor: BVApp.Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally("https://github.com/micuintus/harbour-Berlin-Vegan")
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge * 1.3
            }

            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: BVApp.Theme.secondaryHighlightColor
                height: 2

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge * 1.3
            }

            Label {
                //% "Many thanks goes to the <a href=\"berlinvegan\">editorial "
                //% "team of berlin-vegan.de</a> for creating and maintaining the "
                //% "Berlin-Vegan project with its marvelous restaurant database, "
                //% "which this app uses. This content is released under the terms "
                //% "of the Attribution-NonCommercial 4.0 International Creative "
                //% "Commons license (CC BY-NC 4.0)."
                text: qsTrId("id-many-thanks-to-bvapp-and-license")
                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: BVApp.Theme.paddingLarge
                }

                linkColor: BVApp.Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally("http://www.berlin-vegan.de/team/kontakt/")
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge
            }

            Button {
                            //% "View CC BY-NC"
                text: qsTrId("id-view-cc-by-nc")
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
                height: BVApp.Theme.paddingLarge * 1.3
            }

            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: BVApp.Theme.secondaryHighlightColor
                height: 2

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge * 1.3
            }


            Label {
                //% "Apart from Qt and other wonderful FOSS components of jolla's "
                //% "SailfishOS SDK, this application greatfully makes use of the "
                //% "following third party Free Software projects:"
                text: qsTrId("id-thanks-to-qt-and-other-3rd-party")
                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: BVApp.Theme.paddingLarge
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
