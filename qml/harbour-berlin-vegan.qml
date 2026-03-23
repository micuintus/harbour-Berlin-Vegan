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

import QtQuick
import QtPositioning
import harbour.berlin.vegan 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.ui 1.0 as BVApp

import "pages"
import "pages/about"
import "cover"

BVApp.ApplicationWindow
{
    id: app

    VenueModel {
        id: gJsonVenueModel
    }


    PositionSource {
        id: globalPositionSource
        updateInterval: 5000
        active: Qt.application.state === Qt.ApplicationActive
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
            var favorite_ids = FavoritesManager.getFavoriteIds();
            for (var i = 0; i < favorite_ids.length; i++) {
                gJsonVenueModel.setFavorite(favorite_ids[i], true);
            }
        }
    }

    Connections {
        target: VenueDataLoader
        function onGastroDataReady(json) {
            gJsonVenueModel.importFromJson(JSON.parse(json), VenueModel.Gastro);
            favoritesHook();
        }
        function onShoppingDataReady(json) {
            gJsonVenueModel.importFromJson(JSON.parse(json), VenueModel.Shop);
            favoritesHook();
        }
    }

    Component.onCompleted: {
        VenueDataLoader.loadGastroVenues();
        VenueDataLoader.loadShoppingVenues();
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
                gJsonCollection.searchString = searchString;
            }
    } }

    BVApp.NavigationMenu {
        // Used for Android only (AppDrawer)
        headerView: Image {
            fillMode: Image.PreserveAspectFit
            width: parent.width
            source: "qrc:/images/Platzhalter_v2_mitSchriftzug_header.jpg"
        }

        BVApp.ActionMenuItem {
            menuIcon: BVApp.Theme.iconFor("list")
            //% "Venues"
            text: qsTrId("id-venue-list")

            split: true
            onPageChanged: page.searchString = gJsonCollection.searchString;

            onMenuActivated: {
                gJsonCollection.filterFavorites = false;

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

            split: true
            onPageChanged: page.searchString = gJsonCollection.searchString;

            onMenuActivated: {
                gJsonCollection.filterFavorites = true;

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
            split: true
            splitViewExtraPageComponent: app.initialPage
            pageComponent: VenueFilterSettings {
                jsonModelCollection: gJsonCollection
            }

            onMenuActivated: {
                gJsonCollection.filterFavorites = false;
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
