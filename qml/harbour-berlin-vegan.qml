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


    VenueModel {
        id: jsonVenueModel
    }

    PositionSource {
        id: globalPositionSource
        updateInterval: 5000
        property var oldPosition: QtPositioning.coordinate(0, 0)

     }

    VenueSortFilterProxyModel {
        id: gjsonCollection
        model: jsonVenueModel
        currentPosition: globalPositionSource.position.coordinate
        property alias loaded: jsonVenueModel.loaded
    }

    BVApp.JsonDownloadHelper {
        id: venueDownloadHelper
        onFileLoaded:
        function(json)
        {
            jsonVenueModel.importFromJson(JSON.parse(json), VenueModel.Food);
        }
    }

    BVApp.JsonDownloadHelper {
        id: shoppingDownloadHelper
        onFileLoaded:
        function(json)
        {
            jsonVenueModel.importFromJson(JSON.parse(json), VenueModel.Shopping);
        }
    }


    Component.onCompleted: {
        venueDownloadHelper.loadVenueJson()
        shoppingDownloadHelper.loadShoppingJson()
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
        jsonModelCollection: app.jsonModelCollection
        positionSource: globalPositionSource
    } }

    initialPage: Component { VenueList {
            id: venueList
            positionSource: globalPositionSource
            jsonModelCollection: gjsonCollection

            onSearchStringChanged: {
                gjsonCollection.searchString = searchString
            }
   } }

   BVApp.NavigationMenu {

       BVApp.ActionMenuItem {
            icon: BVApp.Theme.iconBy("food")
            //% "Food"
            text: qsTrId("id-venue-list")

            onClicked: {
                gjsonCollection.filterModelCategory = VenueModel.Food;
                page.searchString = gjsonCollection.searchString
            }

            pageComponent: app.initialPage
       }

       BVApp.ActionMenuItem {
           icon: BVApp.Theme.iconBy("shopping")
           //% "Shopping"
           text: qsTrId("id-shopping-venue-list")

           onClicked: {
               gjsonCollection.filterModelCategory = VenueModel.Shopping;
               page.searchString = gjsonCollection.searchString
           }

           pageComponent: app.initialPage
       }

       BVApp.MenuItem {
            icon: BVApp.Theme.iconBy("about")
            //% "About"
            text: qsTrId("id-about-venue-list")

            page: AboutBerlinVegan { }
        }
    }
}


