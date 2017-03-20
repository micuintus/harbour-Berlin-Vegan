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
import QtQuick.LocalStorage 2.0
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

    property var jsonModelCollection: gjsonVenueModelCollection
    property var db
    property var favorite_ids

    JsonListModel {
        id: jsonVenueModel
        dynamicRoles: true
    }

    BVApp.Collection {
        id: gjsonVenueModelCollection
        model: jsonVenueModel
    }

    JsonListModel {
        id: jsonShoppingModel
        dynamicRoles: true
    }

    BVApp.Collection {
        id: gjsonShoppingModelCollection
        model: jsonShoppingModel
    }

    BVApp.JsonDownloadHelper {
        id: venueDownloadHelper
        onFileLoaded:
        function(json)
        {
            jsonVenueModel.add(JSON.parse(json));
            gjsonVenueModelCollection.loaded = true
        }
    }

    BVApp.JsonDownloadHelper {
        id: shoppingDownloadHelper
        onFileLoaded:
        function(json)
        {
            jsonShoppingModel.add(JSON.parse(json));
            gjsonShoppingModelCollection.loaded = true
        }
    }

    PositionSource {
        id: globalPositionSource
        updateInterval: 5000
        property var oldPosition: QtPositioning.coordinate(0, 0)

        onPositionChanged: {
            if (position.coordinate.distanceTo(oldPosition) > 100)
            {
                gjsonVenueModelCollection.reSort();
                gjsonShoppingModelCollection.reSort();

                oldPosition.latitude  = position.coordinate.latitude
                oldPosition.longitude = position.coordinate.longitude
            }
        }
    }


    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("BerlinVeganDB", "0.1", "Berlin Vegan SQL!", 1000000);
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS BerlinVegan(favorite_id TEXT)");
            favorite_ids = tx.executeSql("SELECT favorite_id FROM BerlinVegan");
        })
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
            jsonModelCollection: app.jsonModelCollection

            onSearchStringChanged: {
                gjsonShoppingModelCollection.searchString = searchString
                gjsonVenueModelCollection.searchString    = searchString
            }
   } }

   BVApp.NavigationMenu {

       BVApp.ActionMenuItem {
            icon: BVApp.Theme.iconBy("food")
            //% "Food"
            text: qsTrId("id-venue-list")

            onClicked: {
                app.jsonModelCollection  = gjsonVenueModelCollection
                page.searchString = gjsonVenueModelCollection.searchString
            }

            pageComponent: app.initialPage
       }

       BVApp.ActionMenuItem {
           icon: BVApp.Theme.iconBy("shopping")
           //% "Shopping"
           text: qsTrId("id-shopping-venue-list")

           onClicked: {
               app.jsonModelCollection  = gjsonShoppingModelCollection
               page.searchString = gjsonShoppingModelCollection.searchString
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


