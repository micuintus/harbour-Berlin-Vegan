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

    property var db
    property var favorite_ids

    VenueModel {
        id: gJsonVenueModel
    }

    PositionSource {
        id: globalPositionSource
        updateInterval: 5000
        property var oldPosition: QtPositioning.coordinate(0, 0)
     }

    VenueSortFilterProxyModel {
        id: gJsonCollection
        model: gJsonVenueModel
        currentPosition: globalPositionSource.position.coordinate
    }
    
    function openDataBase() {
        db = LocalStorage.openDatabaseSync("BerlinVeganDB", "0.1", "Berlin Vegan SQL!", 1000000);
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS BerlinVegan(favorite_id TEXT)");
            favorite_ids = tx.executeSql("SELECT favorite_id FROM BerlinVegan");
        });
    }

    function applyFavoritesFromDataBase()
    {
       for (var i = 0; i < favorite_ids.rows.length; i++) {
           gJsonVenueModel.setFavorite(favorite_ids.rows.item(i).favorite_id, true);
       }
    }

    property int jsonFilesToLoad: 2
    function favoritesHook()
    {
        jsonFilesToLoad--;
        if (jsonFilesToLoad === 0)
        {
            applyFavoritesFromDataBase();
        }
    }

    BVApp.JsonDownloadHelper {
        id: venueDownloadHelper
        onFileLoaded:
        function(json)
        {
            gJsonVenueModel.importFromJson(JSON.parse(json), VenueModel.Food);
            favoritesHook();
        }
    }

    BVApp.JsonDownloadHelper {
        id: shoppingDownloadHelper
        onFileLoaded:
        function(json)
        {
            gJsonVenueModel.importFromJson(JSON.parse(json), VenueModel.Shopping);
            favoritesHook();
        }
    }

    Component.onCompleted: {
        openDataBase();
        venueDownloadHelper.loadVenueJson();
        shoppingDownloadHelper.loadShoppingJson();
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
            positionSource: globalPositionSource
            jsonModelCollection: gJsonCollection
    } }

    initialPage: Component { VenueList {
            id: venueList
            positionSource: globalPositionSource
            jsonModelCollection: gJsonCollection
            currentCategoryLoaded: function () {
                return gJsonVenueModel.loadedCategory & gJsonCollection.filterModelCategory;
            }
            onSearchStringChanged: {
                gJsonCollection.searchString = searchString
            }
    } }

    BVApp.NavigationMenu {

        BVApp.ActionMenuItem {
            menuIcon: BVApp.Theme.iconFor("food")
            //% "Food"
            text: qsTrId("id-venue-list")

            onClicked: {
                gJsonCollection.filterFavorites = false;
                gJsonCollection.filterModelCategory = VenueModel.Food;
                page.searchString = gJsonCollection.searchString
            }

            pageComponent: app.initialPage
        }

        BVApp.ActionMenuItem {
            menuIcon: BVApp.Theme.iconFor("shopping")
            //% "Shopping"
            text: qsTrId("id-shopping-venue-list")

           onClicked: {
               gJsonCollection.filterFavorites = false;
               gJsonCollection.filterModelCategory = VenueModel.Shopping;
               page.searchString = gJsonCollection.searchString
           }

           pageComponent: app.initialPage

        }

        BVApp.ActionMenuItem {
            menuIcon: BVApp.Theme.iconFor("favorite")
            //% "Favorites"
            text: qsTrId("id-favorites-venue-list")

            onClicked: {
                gJsonCollection.filterFavorites = true;
                page.searchString = gJsonCollection.searchString;
            }

            pageComponent: app.initialPage
        }

        BVApp.MenuItem {
            menuIcon: BVApp.Theme.iconFor("filter")
            //% "Filter"
            text: qsTrId("id-filter")
            page: VenueFilterSettings {
                jsonModelCollection: gJsonCollection
            }
        }

        BVApp.MenuItem {
            menuIcon: BVApp.Theme.iconFor("about")
            //% "About"
            text: qsTrId("id-about-venue-list")

            page: AboutBerlinVegan { }
        }
    }
}
