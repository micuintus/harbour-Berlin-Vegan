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
import BerlinVegan.components.platform 1.0 as BVApp

Item {
    property bool collapsed: true
    property var expandItem
    property real collapsedHeight
    property real expandedHeight
    property var contentItem

    clip: true

    height: collapsed
          ? collapsedHeight
          : expandedHeight

    Behavior on height { NumberAnimation { easing.type:  Easing.OutBack } }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: {
            parent.collapsed = !parent.collapsed
        }
    }

    children : [mousearea, contentItem, ramp]

    OpacityRampEffect {
        anchors.fill: parent
        id: ramp
        sourceItem: contentItem
        direction: BVApp.Theme.opacityRampTopToBottom
        enabled: parent.collapsed
    }

}

