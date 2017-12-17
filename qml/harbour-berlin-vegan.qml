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
import harbour.berlin.vegan 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

import "pages"
import "pages/about"
import "cover"

ApplicationWindow
{
    id: app

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

    property int jsonFilesToLoad: 2
    function favoritesHook()
    {
        jsonFilesToLoad--;
        if (jsonFilesToLoad === 0)
        {
            var favorite_ids = BVApp.Database.dbGetFavoriteIds();
            for (var i = 0; i < favorite_ids.rows.length; i++) {
                gJsonVenueModel.setFavorite(favorite_ids.rows.item(i).favorite_id, true);
            }
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
        BVApp.Database.dbInit();
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
            currentCategoryLoaded: gJsonVenueModel.loadedVenueType & gJsonCollection.filterVenueType;
            onSearchStringChanged: {
                gJsonCollection.searchString = searchString
            }
    } }

    BVApp.NavigationMenu {

        BVApp.ActionMenuItem {
            menuIcon: BVApp.Theme.iconFor("food")
            //% "Food"
            text: qsTrId("id-venue-list")

            onPageChanged: page.searchString = gJsonCollection.searchString;

            onClicked: {
                gJsonCollection.filterFavorites = false;
                gJsonCollection.filterVenueType = VenueModel.FoodFlag;
                if (page)
                {
                    page.searchString = gJsonCollection.searchString;
                }
            }

            pageComponent: app.initialPage
        }

        BVApp.ActionMenuItem {
            menuIcon: BVApp.Theme.iconFor("shopping")
            //% "Shopping"
            text: qsTrId("id-shopping-venue-list")

            onPageChanged: page.searchString = gJsonCollection.searchString;

            onClicked: {
               gJsonCollection.filterFavorites = false;
               gJsonCollection.filterVenueType = VenueModel.ShoppingFlag;
               if (page)
               {
                   page.searchString = gJsonCollection.searchString;
               }
           }

           pageComponent: app.initialPage
        }

        BVApp.ActionMenuItem {
            menuIcon: BVApp.Theme.iconFor("favorite")
            //% "Favorites"
            text: qsTrId("id-favorites-venue-list")

            onPageChanged: page.searchString = gJsonCollection.searchString;

            onClicked: {
                gJsonCollection.filterFavorites = true;
                // favorites can be both food and shopping venues and should both be shown in the favorites tab
                gJsonCollection.filterVenueType = VenueModel.FoodFlag | VenueModel.ShoppingFlag;
                if (page)
                {
                    page.searchString = gJsonCollection.searchString;
                }
            }

            pageComponent: app.initialPage
        }

        BVApp.MenuItem {
            menuIcon: BVApp.Theme.iconFor("filter")
            //% "Filter"
            text: qsTrId("id-filter")
            pageComponent: VenueFilterSettings {
                jsonModelCollection: gJsonCollection
            }
        }

        BVApp.MenuItem {
            menuIcon: BVApp.Theme.iconFor("about")
            //% "About"
            text: qsTrId("id-about-venue-list")

            pageComponent: AboutBerlinVegan { }
        }
    }
}
