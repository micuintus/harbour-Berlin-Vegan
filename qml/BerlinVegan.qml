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

import com.cutehacks.gel 1.0

import "pages"
import "cover"

ApplicationWindow
{
    id: app

    Component.onCompleted: {
        var json
        var xhr = new XMLHttpRequest();
        xhr.open("GET","pages/GastroLocations.json" )
        xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE)
                {
                    json = xhr.responseText;
                    jsonModel.add(JSON.parse(json));
                }
        }

        xhr.send();
    }

    PositionSource {
        id: globalPositionSource
        updateInterval: 5000
    }

    onApplicationActiveChanged: {
        if (Qt.application.state === Qt.ApplicationActive) {
            globalPositionSource.start();
        }
        else {
            globalPositionSource.stop();
        }
    }

    Collection {
        id: gjsonModelCollection

        model: JsonListModel {
            id: jsonModel
            dynamicRoles: true
        }

        comparator: function lessThan(a, b) {
            return globalPositionSource.position.coordinate.distanceTo(QtPositioning.coordinate(a.latCoord, a.longCoord))
            < globalPositionSource.position.coordinate.distanceTo(QtPositioning.coordinate(b.latCoord, b.longCoord));
        }
    }

    initialPage: Component { VenueList {
        jsonModelCollection: gjsonModelCollection
        positionSource: globalPositionSource
        id: listPage
    } }

    cover: Component { CoverPage {
        id: cover
        jsonModelCollection: gjsonModelCollection
        positionSource: globalPositionSource
    } }
}


