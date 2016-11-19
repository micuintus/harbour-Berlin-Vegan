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
import QtPositioning 5.2

import harbour.berlin.vegan.gel 1.0
import "../components/distance.js" as Distance

Page {

    id: page

    property var jsonModelCollection
    property var positionSource

    SilicaListView {
        id: listView
        model: jsonModelCollection
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("about/AboutBerlinVegan.qml"))
            }

            MenuItem {
                text: qsTr("Update sorting")
                onClicked: jsonModelCollection.invalidate()
            }
        }

        header: PageHeader {
            title: qsTr("Vegan food nearby")
        }

        delegate: ListItem {
            id: delegate
            width: page.width
            height: childrenRect.height

            Label {
                id: namelabel
                text: model.name
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                font.pixelSize: Theme.fontSizeMedium
                truncationMode: TruncationMode.Fade
                anchors {
                    left: parent.left
                    right: distance.left
                    rightMargin: Theme.paddingSmall
                    leftMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
            }

            Label {
                id: distance
                text: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods ?
                Distance.humanReadableDistanceString(positionSource.position.coordinate,
                                                           QtPositioning.coordinate(model.latCoord, model.longCoord)) : ""
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
            }


            onClicked: pageStack.push(Qt.resolvedUrl("VenueDescription.qml"),
                                      {
                                          restaurant     : model,
                                          positionSource : page.positionSource
                                      } )
        }
        VerticalScrollDecorator {}
    }
}





