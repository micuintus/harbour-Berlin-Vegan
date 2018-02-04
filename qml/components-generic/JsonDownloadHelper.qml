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

import QtQuick 2.2

Timer {

    property var request
    property var onFileLoaded
    property bool isVenue
    interval: 5000

    function _fileRequest(url, save)
    {
        var json
        request = new XMLHttpRequest();
        request.open("GET", url)
        request.onreadystatechange =
        function()
        {
            if (request.readyState === XMLHttpRequest.DONE)
            {
                if (request.status === 200)
                {
                    stop()
                    json = request.responseText;
                    onFileLoaded(json)

                    if (!save)
                    {
                        return;
                    }

                    // e.g. GastroLocations.json
                    var filename = url.substr(url.lastIndexOf('/') + 1);

                    // write JSON to disk
                    if (FileIO.write(filename, json))
                    {
                        console.log("Successfully written " + filename + " to disk")
                    }
                    else
                    {
                        console.error("Error writing: " + filename)
                    }
                }
            }
        };

        request.send();
    }

    function loadVenueJson()
    {
        restart()
        isVenue = true
        _fileRequest("https://www.berlin-vegan.de/app/data/GastroLocations.json", true)
    }

    function loadShoppingJson()
    {
        restart()
        isVenue = false
        _fileRequest("https://www.berlin-vegan.de/app/data/ShoppingLocations.json", true)
    }

    onTriggered: {
        request.abort();
        var filename;
        if (isVenue)
        {
            filename = "GastroLocations.json";
        } else
        {
            filename = "ShoppingLocations.json";
        }

        // use file from disk
        if (FileIO.exists(filename))
        {
            var json = FileIO.read(filename);
            onFileLoaded(json);
            console.log("Successfully loaded " + filename + " from disk")
            return;
        }

        console.log("Fall back to resource collection file for " + filename)
        _fileRequest("qrc:/qml/pages/" + filename, false)
    }
}
