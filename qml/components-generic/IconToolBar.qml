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
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0
import BerlinVegan.components 1.0 as BVApp

Column {
    property var restaurant

    id: column

    Separator {
        width: column.width
        horizontalAlignment: Qt.AlignCenter
        color: BVApp.Theme.secondaryHighlightColor
        height: 2
    }

    RowLayout {
        id: row
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Layout.maximumWidth: column.width/2

        width: column.width

        IconButton {
            icon.source: "image://theme/icon-l-answer?" + (pressed
                         ? BVApp.Theme.highlightColor
                         : BVApp.Theme.primaryColor)
            icon.scale: BVApp.Theme.iconSizeMedium / BVApp.Theme.iconSizeLarge

            onClicked: Qt.openUrlExternally("tel:/" + restaurant.telephone)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            enabled: typeof restaurant["telephone"] !== "undefined"
        }

        IconButton {
            icon.source: "image://theme/icon-m-favorite?" + (pressed
                         ? BVApp.Theme.highlightColor
                         : BVApp.Theme.primaryColor)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            enabled: false
            visible: false
        }


        IconButton {
            icon.source: "image://theme/icon-m-home?" + (pressed
                         ? BVApp.Theme.highlightColor
                         : BVApp.Theme.primaryColor)

            onClicked: Qt.openUrlExternally(restaurant.website.slice(0,4) === "http"
                                            ?             restaurant.website
                                            : "http://" + restaurant.website)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            enabled: typeof restaurant["website"] !== "undefined"
        }

    }

    Separator {
        width: column.width
        horizontalAlignment: Qt.AlignCenter
        color: BVApp.Theme.secondaryHighlightColor
        height: 2
    }
}

