/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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

    initialPage: Component { GastroLocationList {
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


