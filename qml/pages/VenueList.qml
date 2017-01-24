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
import QtLocation 5.0
import "."

import harbour.berlin.vegan.gel 1.0

import "../components/distance.js" as Distance

Page {

    id: page

    property var jsonModelCollection
    property var positionSource

    property bool searchActivated: false

    SilicaListView {
        id: listView
        model: jsonModelCollection
        anchors.fill: parent


        PullDownMenu {
            MenuItem {
                            //% "About"
                text: qsTrId("id-about-venue-list")
                onClicked: pageStack.push(Qt.resolvedUrl("about/AboutBerlinVegan.qml"))
            }
            MenuItem {
                text: searchActivated ?
                                //% "Disable Search"
                          qsTrId("id-disable-search") :
                                //% "Enable Search"
                          qsTrId("id-enable-search")
                onClicked: searchActivated = !searchActivated
            }
        }

        currentIndex: -1

        property  Component searchField:
        SearchField {
            id: searchField
            width: page.width

            property int test: listView.contentHeight

            onTextChanged:
            {
                jsonModelCollection.searchString = searchField.text
            }
        }

        property Component heading:
        PageHeader {
                         //% "Vegan food nearby"
            title: qsTrId("id-vegan-food-nearby")
        }

        header: searchActivated ? searchField : heading

        delegate: ListItem {
            id: delegate
            width: page.width
            contentHeight: namelabel.contentHeight
                         + streetLabel.contentHeight
                         + Theme.paddingSmall*3

            Label {
                id: namelabel
                text: model.name
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                font.pixelSize: Theme.fontSizeMedium
                truncationMode: TruncationMode.Fade
                anchors {
                    top: parent.top
                    left: parent.left
                    right: distance.left

                    topMargin: Theme.paddingSmall
                    rightMargin: Theme.paddingSmall
                    bottomMargin: Theme.paddingSmall
                    leftMargin: Theme.horizontalPageMargin
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

                    baseline: namelabel.baseline

                    topMargin: Theme.paddingSmall
                    bottomMargin: Theme.paddingSmall
                    rightMargin: Theme.horizontalPageMargin
                }
            }

            Label {
                id: streetLabel
                text: model.street

                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor

                truncationMode: TruncationMode.Fade

                anchors {
                    top: namelabel.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: namelabel.right

                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin

                    bottomMargin: Theme.paddingSmall
                }
            }

            onClicked:
            {
                var currRestaurant = jsonModelCollection.at(index)
                pageStack.push(Qt.resolvedUrl("VenueDescription.qml"),
                               {
                                   restaurant     : currRestaurant,
                                   positionSource : page.positionSource
                               });

                var mapPage = pageStack.pushAttached(Qt.resolvedUrl("VenueMapPage.qml"),
                               {
                                   venueCoordinate: QtPositioning.coordinate(currRestaurant.latCoord,
                                                                             currRestaurant.longCoord),
                                   positionSource: page.positionSource,
                                   name: currRestaurant.name
                               });

                // TODO: Directly assigning a coordinate property to Map.center seems to be broken
                // with the current Qt version (5.2)
                mapPage.map.addMapItem(mapPage.venueMarker)
                mapPage.map.addMapItem(mapPage.currentPosition)

                mapPage.setMapCenter(mapPage.venueMarker.coordinate)

                // Seems to be broken with the current version of Qt :/
                mapPage.map.fitViewportToMapItems()
            }


        }
        VerticalScrollDecorator {}
    }
}





