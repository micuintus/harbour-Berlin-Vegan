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

ListModel
{
    property var restaurant;
    id: model

    Component.onCompleted: {
        /* NOTE: Unfortunately, we cannot go for static assignment here
                 --- ListElement { day: qsTr("Monday), hours: restautant.otMon }, ...,
                 because dynamic role values arent't supported in Qt 5.2;
                 see http://stackoverflow.com/questions/7659442/listelement-fields-as-properties */

        append({"day":qsTr("Monday"),    "hours": restaurant.otMon});
        append({"day":qsTr("Tuesday"),   "hours": restaurant.otTue});
        append({"day":qsTr("Wednesday"), "hours": restaurant.otWed});
        append({"day":qsTr("Thursday"),  "hours": restaurant.otThu});
        append({"day":qsTr("Friday"),    "hours": restaurant.otFri});
        append({"day":qsTr("Saturday"),  "hours": restaurant.otSat});
        append({"day":qsTr("Sunday"),    "hours": restaurant.otSun});
    }
}

