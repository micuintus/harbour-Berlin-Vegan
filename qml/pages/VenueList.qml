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
import BerlinVegan.components 1.0 as BVApp
import "."

import harbour.berlin.vegan.gel 1.0

import "../components-generic/distance.js" as Distance

BVApp.Page {

    id: page
                 //% "Berlin-Vegan"
    title: qsTrId("id-berlin-vegan")

    property var jsonModelCollection
    property var positionSource
    property alias flickable: listView

    SilicaListView {
        id: listView
        model: jsonModelCollection
        anchors.fill: parent

        BusyIndicator {
            id: busyGuy
            anchors.centerIn: parent
            running: !jsonModelCollection.loaded
            size: BVApp.Theme.busyIndicatorSizeLarge
        }

        currentIndex: -1

        header: SearchField {
            id: searchField
            width: page.width

            property int test: listView.contentHeight

            onTextChanged:
            {
                jsonModelCollection.searchString = searchField.text
            }
        }

        delegate: ListItem {
            id: delegate
            width: page.width
            contentHeight: namelabel.contentHeight
                         + streetLabel.contentHeight
                         + BVApp.Theme.paddingSmall*3

            Label {
                id: namelabel
                text: model.name
                color: delegate.highlighted ? BVApp.Theme.highlightColor : BVApp.Theme.primaryColor

                font.pixelSize: BVApp.Theme.fontSizeMedium
                truncationMode: TruncationMode.Fade
                anchors {
                    top: parent.top
                    left: parent.left
                    right: distance.left

                    topMargin: BVApp.Theme.paddingSmall
                    rightMargin: BVApp.Theme.paddingSmall
                    bottomMargin: BVApp.Theme.paddingSmall
                    leftMargin: BVApp.Theme.horizontalPageMargin
                }
            }

            Label {
                id: distance
                text: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods ?
                Distance.humanReadableDistanceString(positionSource.position.coordinate,
                                                           QtPositioning.coordinate(model.latCoord, model.longCoord)) : ""
                color: delegate.highlighted ? BVApp.Theme.highlightColor : BVApp.Theme.primaryColor
                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
                anchors {
                    right: parent.right

                    baseline: namelabel.baseline

                    topMargin: BVApp.Theme.paddingSmall
                    bottomMargin: BVApp.Theme.paddingSmall
                    rightMargin: BVApp.Theme.horizontalPageMargin
                }
            }

            Label {
                id: streetLabel
                text: model.street

                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                color: BVApp.Theme.secondaryColor

                truncationMode: TruncationMode.Fade

                anchors {
                    top: namelabel.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: namelabel.right

                    leftMargin: BVApp.Theme.horizontalPageMargin
                    rightMargin: BVApp.Theme.horizontalPageMargin

                    topMargin: BVApp.Theme.paddingSmall
                    bottomMargin: BVApp.Theme.paddingSmall
                }
            }

            onClicked:
            {
                // ios: keyboard stays visible, if user used search field before clicking and did not press Return key
                Qt.inputMethod.hide();

                var currRestaurant = jsonModelCollection.at(index)
                pageStack.push(Qt.resolvedUrl("VenueDescription.qml"),
                               {
                                   restaurant     : currRestaurant,
                                   positionSource : page.positionSource
                               });

                // The icon parameter is only used on v-play
                pageStack.pushAttached(Qt.resolvedUrl("VenueMapPage.qml"),
                               {
                                   venueCoordinate: QtPositioning.coordinate(currRestaurant.latCoord,
                                                                             currRestaurant.longCoord),
                                   positionSource: page.positionSource,
                                   name: currRestaurant.name
                               }, BVApp.Theme.iconBy("mapmarker")
                               );
            }
        }
        VerticalScrollDecorator {}
    }
}





