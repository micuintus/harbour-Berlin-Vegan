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

// We cannot use upstream implementation, because SailfishOS does not support
// Qt Quick Controls 2 at the moment (see PageIndicator.qml)
ListView {
    interactive: true
    currentIndex: 0

    spacing: 0
    orientation: Qt.Horizontal
    snapMode: ListView.SnapOneItem
    boundsBehavior: Flickable.StopAtBounds

    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: 0
    preferredHighlightEnd: 0
    highlightMoveDuration: 250

    // This number needs to be pretty high, otherwise the image components are destroyed and recreated all the time,
    // which would lead to white spaces during fast scrolling. This can be checked by putting:
    //
    //  Component.onCompleted: console.log("created:", index)
    //  Component.onDestruction: console.log("destroyed:", index)
    //
    // into the delegate component.
    cacheBuffer: 9999
}
