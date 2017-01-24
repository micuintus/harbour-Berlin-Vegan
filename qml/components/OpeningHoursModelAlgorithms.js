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

function cleanUpOpeningHoursModel(openingHoursModel)
{
    var count = openingHoursModel.count;
    for (var i = 0; i < count; i++)
    {
        while (i < count && openingHoursModel.get(i).hours === "flagDeleteDummy")
        {
            openingHoursModel.remove(i);
            count--;
        }

        if (openingHoursModel.get(i).hours === "")
        {
            //% "closed"
            openingHoursModel.set(i, {"hours": qsTrId("id-closed")});
        }
    }
}

function mergeElements(openingHoursModel, from, to)
{
    var fromElementDay = openingHoursModel.get(from).day;
    var toElementDay   = openingHoursModel.get(to).day;
    var hours          = openingHoursModel.get(from).hours

    openingHoursModel.set(from, {"day":fromElementDay + " - " + toElementDay, "hours":hours});

    for (var i = from + 1; i <= to; i++)
    {
        openingHoursModel.set(i, {"day":"flagDeleteDummy", "hours":"flagDeleteDummy"});
    }
}

function condenseOpeningHoursModel(openingHoursModel)
{
    var initSize = openingHoursModel.count;
    var lastEqualItemIndex = -1;

    if (initSize <= 1)
    {
        return;
    }

    // iterating from the first to the second last item, models are 0 indexed
    for (var i = 0; i <= initSize - 2 ; i++)
    {
        var currElem = openingHoursModel.get(i);
        var nextElem = openingHoursModel.get(i+1);

        if (currElem.hours === nextElem.hours)
        {
            if (lastEqualItemIndex === -1)
            {
                lastEqualItemIndex = i;
            }

            if (i === initSize - 2)
            {
                mergeElements(openingHoursModel, lastEqualItemIndex, i + 1);
            }
        }
        else
        {
            if (lastEqualItemIndex !== -1)
            {
                mergeElements(openingHoursModel, lastEqualItemIndex, i);
                lastEqualItemIndex = -1;
            }
        }
    }

    cleanUpOpeningHoursModel(openingHoursModel);
}
