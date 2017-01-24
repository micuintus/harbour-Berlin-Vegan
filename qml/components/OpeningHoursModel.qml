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
                 --- ListElement { day: qsTrId("id-monday), hours: restautant.otMon }, ...,
                 because dynamic role values arent't supported in Qt 5.2;
                 see http://stackroverflow.com/questions/7659442/listelement-fields-as-properties */
                             //% "Monday"
        append({"day": qsTrId("id-monday"),    "hours": restaurant.otMon});
                             //% "Tuesday"
        append({"day": qsTrId("id-tuesday"),   "hours": restaurant.otTue});
                             //% "Wednesday"
        append({"day": qsTrId("id-wednesday"), "hours": restaurant.otWed});
                             //% "Thursday"
        append({"day": qsTrId("id-thursday"),  "hours": restaurant.otThu});
                             //% "Friday"
        append({"day": qsTrId("id-friday"),    "hours": restaurant.otFri});
                             //% "Saturday"
        append({"day": qsTrId("id-saturday"),  "hours": restaurant.otSat});
                             //% "Sunday"
        append({"day": qsTrId("id-sunday"),    "hours": restaurant.otSun});
    }
}

