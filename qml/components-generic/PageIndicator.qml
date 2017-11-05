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

import BerlinVegan.components.platform 1.0 as BVApp

// We cannot use upstream implementation, because SailfishOS does not support
// Qt Quick Controls 2 at the moment (see SwipeView.qml)
ListView {
    id: root

    width: contentItem.width
    height: BVApp.Theme.pageIndicatorSmall

    spacing: BVApp.Theme.paddingSmall
    orientation: Qt.Horizontal

    delegate: Rectangle {
        implicitWidth: BVApp.Theme.pageIndicatorSmall
        implicitHeight: BVApp.Theme.pageIndicatorSmall

        radius: width / 2
        color: BVApp.Theme.pageIndicatorColor

        opacity: index === root.currentIndex ? 0.95 : pressed ? 0.7 : 0.45
        Behavior on opacity { OpacityAnimator { duration: 100 } }
    }
}
