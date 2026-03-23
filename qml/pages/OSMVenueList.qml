/**
 *
 *  This file is part of the Berlin-Vegan guide (SailfishOS app version),
 *  Copyright 2015-2018 (c) by micu <micuintus.de> (post@micuintus.de).
 *  Copyright 2017-2018 (c) by jmastr <veggi.es> (julian@veggi.es).
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

import QtQuick 2.5
import QtPositioning 5.2

import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.ui 1.0 as BVApp

import harbour.berlin.vegan 1.0

BVApp.Page {
    id: page
    title: "OSM Nearby Venues"

    property alias venues: osmProvider
    property var positionSource: null
    
    Component.onCompleted: {
        if (positionSource && positionSource.position && positionSource.position.coordinate) {
            // Fetch nearby venues when the page loads
            osmProvider.fetchNearbyVenues(positionSource.position.coordinate, 1000);
        } else {
            // Use a default Berlin coordinate if position is not available
            var berlinCoordinate = QtPositioning.coordinate(52.5200, 13.4050);
            osmProvider.fetchNearbyVenues(berlinCoordinate, 1000);
        }
    }

    OSMDataProvider {
        id: osmProvider
        onVenuesFound: {
            venuesModel.clear()
            for (var i = 0; i < venues.length; i++) {
                venuesModel.append(venues[i])
            }
        }
        onError: {
            BVApp.Dialogs.showError(message)
        }
    }

    BVApp.SearchField {
        id: searchField
        width: parent.width
        flickableForSailfish: listView
        
        onAccepted: {
            if (text.trim().length > 0) {
                // Search for venues by name
                if (positionSource && positionSource.position && positionSource.position.coordinate) {
                    osmProvider.lookupVenue(text, positionSource.position.coordinate);
                } else {
                    // Use a default Berlin coordinate if position is not available
                    var berlinCoordinate = QtPositioning.coordinate(52.5200, 13.4050);
                    osmProvider.lookupVenue(text, berlinCoordinate);
                }
            } else {
                // If search field is empty, show nearby venues
                if (positionSource && positionSource.position && positionSource.position.coordinate) {
                    osmProvider.fetchNearbyVenues(positionSource.position.coordinate, 1000);
                } else {
                    // Use a default Berlin coordinate if position is not available
                    var berlinCoordinate = QtPositioning.coordinate(52.5200, 13.4050);
                    osmProvider.fetchNearbyVenues(berlinCoordinate, 1000);
                }
            }
        }
    }

    BVApp.ListView {
        id: listView
        anchors {
            top: searchField.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        model: ListModel {
            id: venuesModel
        }

        BVApp.Label {
            id: emptyText
            anchors.fill: parent
            text: qsTrId("id-no-results")
            wrapMode: Text.WordWrap
            color: BVApp.Theme.secondaryColor
            font.pixelSize: BVApp.Theme.fontSizeMedium
            visible: venuesModel.count === 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        BVApp.BusyIndicator {
            id: busyGuy
            anchors.centerIn: parent
            running: osmProvider.isLoading
            size: BVApp.Theme.busyIndicatorSizeLarge
        }

        delegate: VenueListItem {
            // The VenueListItem will use model.name and model.street from the model
            // We only need to set the distanceText property
            distanceText: positionSource && positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods ?
                BVApp.DistanceFormatter.formatDistance(BVApp.GeoUtils.distanceToPosition(positionSource, model.lat, model.lon)) : ""

            onClicked: {
                // Use the same pattern as in VenueList.qml
                var venue = {
                    name: model.name,
                    street: model.street,
                    cuisine: model.cuisine,
                    opening_hours: model.opening_hours,
                    phone: model.phone,
                    website: model.website,
                    lat: model.lat,
                    lon: model.lon
                };
                // Use pageStack.push instead of BVApp.Pages.show
                pageStack.push(Qt.resolvedUrl("VenueDescription.qml"), {
                    "restaurant": venue
                });
            }
        }

        onModelChanged: {
            currentIndex = -1
        }

        onContentYChanged: {
            Qt.inputMethod.hide()
        }
    }
}
