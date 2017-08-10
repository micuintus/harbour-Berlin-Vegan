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

SilicaListView {

    width: parent.width
    height: contentItem.childrenRect.height

    delegate: ListItem {

        width: parent.width
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: BVApp.Theme.fontSizeMedium
                color: BVApp.Theme.secondaryColor
                text: model.name
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingMedium
            }

            Label {
               anchors {
                   horizontalCenter: parent.horizontalCenter
               }

               font.pixelSize: BVApp.Theme.smallLinkFontSize
               color: BVApp.Theme.secondaryColor
               textFormat: Text.StyledText

               text: "<a href='URL'>" + model.url + "</a>"
               linkColor: BVApp.Theme.linkColor
               onLinkActivated: Qt.openUrlExternally(model.url)
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge
            }

            Button {
                id: gplButton
                            //% "View license"
                text: qsTrId("id-view-license")
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
                height: BVApp.Theme.paddingLarge
            }

            Separator {
                id: lastSeperator
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: BVApp.Theme.secondaryHighlightColor
                height: 2

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
