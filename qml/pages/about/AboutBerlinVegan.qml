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
import BerlinVegan.components.platform 1.0 as BVApp

BVApp.Page {

    id: page
                //% "About"
    title: qsTrId("id-about-page-title")

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width

            PageHeader {
                id: pageHeader
                visible: BVApp.Platform.isSailfish
                title: page.title
            }

            Image  {
                id: logo
                visible: BVApp.Platform.isSailfish

                source: "BerlinVegan.svg"
                sourceSize.width: page.width / 3.2
                sourceSize.height: page.width / 3.2
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            // Semi-hack to make different Layouts on Sailfish and V-Play possible
            Item {
                width: page.width
                height: BVApp.Platform.isVPlay ?
                            vPlayHeaderPicture.height * 0.95
                          : titleColumn.height

                Image  {
                    id: vPlayHeaderPicture
                    visible: BVApp.Platform.isVPlay

                    fillMode: Image.PreserveAspectCrop
                    source: "qrc:/images/Platzhalter_v2_mitSchriftzug.jpg"
                    sourceSize.width: parent.width
                    width: parent.width
                }

                Column {
                    id: titleColumn
                    width: parent.width

                    Item {
                        width: parent.width
                        height: BVApp.Platform.isVPlay ?
                                    vPlayHeaderPicture.width * 0.04
                                  : BVApp.Theme.paddingMedium
                    }

                    Label {
                                    //% "Berlin-Vegan"
                        text: qsTrId("id-berlin-vegan")
                        font.pixelSize: BVApp.Platform.isVPlay ?
                                          BVApp.Theme.fontSizeExtraLarge
                                        : BVApp.Theme.fontSizeLarge

                        color: BVApp.Platform.isVPlay ?
                                 BVApp.Theme.highlightDimmerColor
                               : BVApp.Theme.highlightColor
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Item {
                        width: parent.width
                        height: BVApp.Platform.isVPlay ?
                                    vPlayHeaderPicture.width * 0.02
                                  : BVApp.Theme.paddingMedium
                    }

                    Label {
                                  //% "Cross-platform app"
                        text: qsTrId("id-about-cross-platform-app")
                        font.pixelSize: BVApp.Platform.isVPlay ?
                                          BVApp.Theme.fontSizeExtraSmall
                                        : BVApp.Theme.fontSizeSmall
                        color: BVApp.Platform.isVPlay ?
                                 BVApp.Theme.highlightDimmerColor
                               : BVApp.Theme.highlightColor
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Label {
                                //% "for SailfishOS and iOS"
                        text: qsTrId("id-about-for-sailfish-and-ios")
                        font.pixelSize: BVApp.Platform.isVPlay ?
                                          BVApp.Theme.fontSizeExtraSmall
                                        : BVApp.Theme.fontSizeSmall
                        color: BVApp.Platform.isVPlay ?
                                 BVApp.Theme.highlightDimmerColor
                               : BVApp.Theme.highlightColor
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Item {
                visible: BVApp.Platform.isSailfish
                width: parent.width
                height: BVApp.Theme.paddingMedium * 1.3
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
                height: BVApp.Theme.paddingLarge*2
            }

            Label {
                    //% "Development:"
                text: qsTrId("id-development")
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Label {
                text: "micu <a href='ref'>&lt;www.micuintus.de&gt;</a>"
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.highlightColor
                textFormat: Text.StyledText
                linkColor: BVApp.Theme.linkColor
                onLinkActivated: Qt.openUrlExternally("http://www.micuintus.de")

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Label {
                text: "Julian <julian@veggi.es>"
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.highlightColor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge

            }

            Label {
                         //% "UI design:"
                text: qsTrId("id-ui-design")
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }


            Label {
                text: "Robin <robin@siebzehn3.de>"
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.highlightColor
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
                //% "Berlin-Vegan for SailfishOS and iOS is <a href='ref'>Free Software</a>: "
                //% "you can redistribute it and/or modify it under the terms of the "
                //% "GNU General Public License as published by the "
                //% "Free Software Foundation, either version 2 of the license, or "
                //% "(at your option) any later version."
                text: qsTrId("id-bvapp-is-free-software")
                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                linkColor: BVApp.Theme.linkColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: BVApp.Theme.paddingLarge
                }
                onLinkActivated:  Qt.openUrlExternally("http://www.micuintus.de/2010/10/27/die-gesellschaftliche-bedeutung-freier-software-und-offener-standards/")
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

                font.pixelSize: BVApp.Theme.smallLinkFontSize
                color: BVApp.Theme.secondaryColor
                linkColor: BVApp.Theme.linkColor
                textFormat: Text.StyledText

                text: "<a href='ref'>https://github.com/micuintus/harbour-Berlin-Vegan</a>"
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
                //% "Many thanks goes to the <a href='ref'>editorial "
                //% "team of berlin-vegan.de</a> for creating and maintaining the "
                //% "Berlin-Vegan project with its marvelous restaurant database, "
                //% "which this app uses. This content is released under the terms "
                //% "of the Attribution-NonCommercial 4.0 International Creative "
                //% "Commons license (CC BY-NC 4.0)."
                text: qsTrId("id-many-thanks-to-bvapp-and-license")
                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                linkColor: BVApp.Theme.linkColor

                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: BVApp.Theme.paddingLarge
                }

                onLinkActivated: Qt.openUrlExternally("http://www.berlin-vegan.de/team/wir/")
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
                //% "Berlin-Vegan for iOS and SailfishOS is being developed "
                //% "with the free and open source cross-platform framework <a href='ref'>Qt</a>. "
                //% "While the app uses jolla's native Qt-based SDK on SailfishOS, "
                //% "on iOS it is realized with the cross-platform V-Play Engine."
                text: qsTrId("id-thanks-to-qt")
                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                linkColor: BVApp.Theme.linkColor

                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: BVApp.Theme.paddingLarge
                }

                onLinkActivated: Qt.openUrlExternally("https://www.qt.io/")
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingMedium
                visible: BVApp.Platform.isVPlay
            }

            Label {
                //% "We would like to thank Mapbox for donating <a href='ref'>their astonishing "
                //% "Mapbox GL Plugin</a> to the Qt project, which makes hardware accelerated vector maps "
                //% "possible for this app."
                text: qsTrId("id-thanks-to-mapbox")

                visible: BVApp.Platform.isVPlay

                wrapMode: Text.WordWrap
                font.pixelSize: BVApp.Theme.fontSizeSmall
                color: BVApp.Theme.secondaryColor
                linkColor: BVApp.Theme.linkColor
                textFormat: Text.StyledText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: BVApp.Theme.paddingLarge
                }

                onLinkActivated: Qt.openUrlExternally("http://blog.qt.io/blog/2016/10/04/customizable-vector-maps-with-the-mapbox-qt-sdk")
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
                //% "Moreover, this application greatfully makes use of the "
                //% "following third party Free Software projects:"
                text: qsTrId("id-thanks-to-other-3rd-party-sw")
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
                       name: "Berlin-Vegan (Android app)"
                       url: "https://github.com/Berlin-Vegan/berlin-vegan-guide"
                       licenseName: "GPLv2"
                       licenseFile: "LICENSE"
                   }

                   ListElement {
                       name: "Cutehacks Gel"
                       url: "https://github.com/Cutehacks/gel/"
                       licenseName: "MIT"
                       licenseFile: "LICENSE.Cutehacks"
                   }

                   ListElement {
                       name: "TinyColor"
                       url: "https://github.com/bgrins/TinyColor"
                       licenseName: "MIT"
                       licenseFile: "LICENSE.TinyColor"
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

                   Component.onCompleted:
                   {
                       // HACK B/C ListElement doesn't support 'real' properties
                       // and we only want to include this ...
                       if (BVApp.Platform.isVPlay)
                       {
                           insert(0,
                           {
                               "name": "Sailfish Silica",
                               "url": "https://github.com/dm8tbr/sailfishsilica-qt5",
                               "licenseName": "MIT",
                               "licenseFile": "qrc:/imports/Sailfish/Silica/OpacityRampEffectBase.qml",
                            });
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
