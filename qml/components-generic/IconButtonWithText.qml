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
import Sailfish.Silica 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp
import harbour.berlin.vegan 1.0

Column
{
    property alias type: button.type
    property alias color: button.color
    property alias iconScale: button.scale
    property alias text: subtitle.text
    signal clicked


    BVApp.IconButton
    {
        id: button
        onClicked: parent.clicked()
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: subtitle
        font.pixelSize: BVApp.Theme.fontSizeTiny
        font.letterSpacing: 1.1
        color: BVApp.Theme.secondaryColor
        anchors.horizontalCenter: parent.horizontalCenter

    }
}

