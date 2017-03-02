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
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

import "pages"
import "pages/about"
import "cover"

ApplicationWindow
{
    id: app

    JsonListModel {
        id: jsonModel
        dynamicRoles: true
    }

    Collection {
        id: gjsonModelCollection

        property string searchString: ""
        property bool   loaded: false

        onSearchStringChanged: reFilter()

        model: jsonModel

        comparator: function lessThan(a, b) {
            return globalPositionSource.position.coordinate.distanceTo(QtPositioning.coordinate(a.latCoord, a.longCoord))
            < globalPositionSource.position.coordinate.distanceTo(QtPositioning.coordinate(b.latCoord, b.longCoord));
        }

        filter: function(item) {
           return item.name.toLowerCase().search(searchString.toLowerCase()) !== -1
        }
    }

    PositionSource {
        id: globalPositionSource
        updateInterval: 5000
        property var oldPosition: QtPositioning.coordinate(0, 0)

        onPositionChanged: {
            console.log(oldPosition + " " + position.coordinate + " " + position.coordinate.distanceTo(oldPosition))
            if (position.coordinate.distanceTo(oldPosition) > 100)
            {
                gjsonModelCollection.reSort();

                oldPosition.latitude  = position.coordinate.latitude
                oldPosition.longitude = position.coordinate.longitude
            }
        }
    }

    BVApp.JsonDownloadHelper {
        id: downloadHelper
        onFileLoaded:
        function(json)
        {
            jsonModel.add(JSON.parse(json));
            gjsonModelCollection.loaded = true
        }
    }

    Component.onCompleted: {
        downloadHelper.loadVenueJson()
    }

    Connections {
        target: Qt.application
        onStateChanged: {
            if (Qt.application.state === Qt.ApplicationActive) {
                globalPositionSource.start();
            }
            else {
                globalPositionSource.stop();
            }
        }
    }

    cover: Component { CoverPage {
        id: cover
        jsonModelCollection: gjsonModelCollection
        positionSource: globalPositionSource
    } }

    initialPage: VenueList {
        jsonModelCollection: gjsonModelCollection
        positionSource: globalPositionSource
        id: listPage
    }

   BVApp.NavigationMenu {
        id: myMenu

        flickable: initialPage.flickable

        initialMenuItem: BVApp.MenuItem {
                pageToVisit: initialPage
                icon: BVApp.Theme.iconBy("list")
                //% "List view"
                text: qsTrId("id-venue-list")
        }

        BVApp.MenuItem {
            pageToVisit: AboutBerlinVegan { }
            icon: BVApp.Theme.iconBy("about")
            //% "About"
            text: qsTrId("id-about-venue-list")
        }
    }
}


