/**
 *
 *  This file is part of the Berlin-Vegan guide (SailfishOS app version),
 *  Copyright 2015-2018 (c) by micu <micuintus.de> (micuintus@gmx.de).
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

import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

import harbour.berlin.vegan 1.0

BVApp.Page {

    id: page
                 //% "Berlin-Vegan"
    title: qsTrId("id-berlin-vegan")

    property alias jsonModelCollection: listView.model
    property bool currentCategoryLoaded: false
    property var positionSource
    property alias flickable: listView
    property alias searchString: searchField.text


    BVApp.SearchField {
       id: searchField
       width: page.width

       flickableForSailfish: listView
    }

    SilicaListView {
        id: listView
        anchors {
            top: searchField.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Label {
            id: emptyText
            anchors.fill: parent
                        //% "No filter or search results"
            text: qsTrId("id-no-results")
            wrapMode: Text.WordWrap

            color: BVApp.Theme.secondaryColor
            font.pixelSize: BVApp.Theme.fontSizeMedium

            visible: listView.count === 0 && currentCategoryLoaded

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        BusyIndicator {
            id: busyGuy
            anchors.centerIn: parent
            running: !currentCategoryLoaded
            size: BVApp.Theme.busyIndicatorSizeLarge
        }

        // Required to hinder the virtual
        // keyboard from disappearing while typing
        onModelChanged: {
            currentIndex = -1
        }

        onContentYChanged: {
            // ios: keyboard stays visible, if user used search field before scrolling and did not press Return key
            Qt.inputMethod.hide();
        }

        delegate: BVApp.VenueListItem {
            width: page.width

            distanceText: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods ?
                      BVApp.DistanceAlgorithms.humanReadableDistanceString(positionSource.position.coordinate,
                                                                 QtPositioning.coordinate(model.latCoord, model.longCoord)) : ""
            onClicked:
            {
                // ios: keyboard stays visible, if user used search field before clicking and did not press Return key
                Qt.inputMethod.hide();

                var currRestaurant = jsonModelCollection.item(index);
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
                                   vegan: currRestaurant.vegan,
                                   name: currRestaurant.name
                               }, BVApp.Theme.iconFor("locationarrow")
                               );
            }
        }

        VerticalScrollDecorator {}
    }

    onPushed: pageStack.pushAttached("qrc:/qml/pages/VenueMapOverviewPage.qml",
                            {
                                "positionSource": globalPositionSource,
                                "model": gJsonCollection
                            }, BVApp.Theme.iconFor("map")
                        );
}

