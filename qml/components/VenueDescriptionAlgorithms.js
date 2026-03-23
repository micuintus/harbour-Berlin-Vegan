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

.pragma library

// VenueModel.VenueVegCategory enum values
var Omnivorous = 1;
var OmnivorousVeganLabeled = 2;
var Vegetarian = 3;
var VegetarianVeganLabeled = 4;
var Vegan = 5;

function valueUnknown(key)
{
    return (typeof key === "undefined") || (key === -1);
}

function defaultBooleanProperty(key)
{
    switch (key)
    {
                              //% "yes"
        case 1:  return qsTrId("id-yes");
                              //% "no"
        case 0:  return qsTrId("id-no");
                              //% "unknown"
        default: return qsTrId("id-unknown");
    }
}

function restaurantCategory(key)
{
    switch(key)
    {
        case Omnivorous:
                      //% "omnivorous"
            return qsTrId("id-omnivorous");

        case OmnivorousVeganLabeled:
                      //% "omnivorous \n(vegan dishes labeled)"
            return qsTrId("id-omnivorous-labeled");

        case Vegetarian:
                      //% "vegetarian"
            return qsTrId("id-vegetarian");

        case VegetarianVeganLabeled:
                      //% "vegetarian \n(vegan dishes labeled)"
            return qsTrId("id-vegetarian-labeled");

        case Vegan:
                      //% "vegan"
            return qsTrId("id-vegan");

                              //% "unknown"
        default: return qsTrId("id-unknown");
    }
}

function seatProperty(key)
{
    if (typeof key === "undefined")
    {             //% "unknown"
        return qsTrId("id-unknown");
    }

    switch (key)
    {                      //% "unknown"
        case -1: return qsTrId("id-unknown");
                              //% "no"
        case  0: return qsTrId("id-no");
        default: return key;
    }
}
