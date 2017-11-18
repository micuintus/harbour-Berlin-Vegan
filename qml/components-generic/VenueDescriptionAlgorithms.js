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

.pragma library
.import harbour.berlin.vegan 1.0 as BVApp


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
        case BVApp.VenueModel.Omnivore:
                      //% "omnivore"
            return qsTrId("id-omnivore");

        case BVApp.VenueModel.OmnivoreVeganDeclared:
                      //% "omnivore \n(vegan declared)"
            return qsTrId("id-omnivore-declared");

        case BVApp.VenueModel.Vegetarian:
                      //% "vegetarian"
            return qsTrId("id-vegetarian");

        case BVApp.VenueModel.VegetarianVeganDeclared:
                      //% "vegetarian \n(vegan declared)"
            return qsTrId("id-vegetarian-declared");

        case BVApp.VenueModel.Vegan:
                      //% "vegan"
            return qsTrId("id-vegan");

                              //% "unknown"
        default: return qsTrId("id-unknown");
    }
}

function seatProperty(key)
{
    switch (key)
    {
                              //% "unknown"
        case -1: return qsTrId("id-unknown");
                              //% "no"
        case  0: return qsTrId("id-no");
        default: return key;
    }
}
