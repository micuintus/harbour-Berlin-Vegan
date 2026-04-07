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

            // Load OSM data AFTER BV data so deduplication works
            OSMProvider.loadMetroArea();
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

    Connections {
        target: OSMProvider
        function onVenuesReady(venues) {
            gJsonVenueModel.importOSMVenues(venues);
            // Fill missing street addresses in background
            ReverseGeocoder.enrichModel(gJsonVenueModel);
        }
    }

    Component.onCompleted: {
        VenueDataLoader.loadGastroVenues();
        VenueDataLoader.loadShoppingVenues();
        // OSM data loads after BV data (in favoritesHook) for deduplication

        // ACCESS_FINE_LOCATION is in AndroidManifest.xml, but Android 6+
        // requires a runtime grant as well.  PositionSource (and therefore the
        // own-location marker) fail silently without it.
        // The old AppMap { showUserPosition: true } handled this internally;
        // we must do it explicitly now that we use a bare QL.Map.
        if (typeof nativeUtils !== "undefined") {
            nativeUtils.requestPermission(NativeUtils.PermissionLocation,
                function(granted) {
                    if (!granted)
                        console.warn("Location permission denied — own-location marker disabled")
                })
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
                gJsonCollection.searchString = searchString;
            }
    } }

    BVApp.NavigationMenu {
        id: navMenu

        // Used for Android only (AppDrawer).
        // A green Rectangle fills the entire header area so the spacer above
        // the skyline image matches the navigation bar colour.
        // The skyline image is offset by navigationBarOffset (the action-bar
        // height) so it appears fully below the overlaying nav bar.
        headerView: Rectangle {
            color: BVApp.Theme.highlightColor
            width: parent.width
            height: navMenu.navigationBarOffset
                    + (skylineImage.implicitWidth > 0
                       ? skylineImage.implicitHeight * (width / skylineImage.implicitWidth)
                       : 0)

            Image {
                id: skylineImage
                y: navMenu.navigationBarOffset
                width: parent.width
                height: implicitWidth > 0
                        ? implicitHeight * (width / implicitWidth)
                        : 0
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/Platzhalter_v2_mitSchriftzug_header.jpg"
            }
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
