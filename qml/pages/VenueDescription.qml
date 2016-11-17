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
import QtPositioning 5.0

import "../components"

Page {

    id: page

    property var restaurant
    property var positionSource

    SilicaFlickable {
        id: flicka
        anchors.fill: parent
        readonly property var nonDescriptionHeaderHeight: locationheader.height + iconToolBar.height
        contentHeight: descriptionText.y + descriptionText.height + Theme.paddingLarge
        property real scrolledUpRatio: 1 - (contentY / nonDescriptionHeaderHeight)

        VerticalScrollDecorator {}

        VenueDescriptionHeader {
            id: locationheader
            name: restaurant.name
            street: restaurant.street
            pictures: restaurant.pictures
            restaurantCoordinate: QtPositioning.coordinate(restaurant.latCoord, restaurant.longCoord)
            positionSource: page.positionSource

            opacity: flicka.scrolledUpRatio
            height: page.height / 3
            shrinkHeightBy: flicka.contentY

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        }

        IconToolBar {
            id: iconToolBar
            restaurant: page.restaurant

            anchors {
                left: parent.left
                right: parent.right
                top: locationheader.bottom
                margins: Theme.paddingMedium
            }

            opacity: flicka.scrolledUpRatio
        }

        CollapsibleItem {
            id: detailsCollapsible

            collapsedHeight: venueDetails.collapsedHeight
            expandedHeight: venueDetails.expandedHeight

            anchors {
                left: parent.left
                right: parent.right
                top: iconToolBar.bottom
            }

            contentItem: VenueDetails {
                id: venueDetails
                restaurant: page.restaurant

                anchors.fill: parent
            }
        }

        Label {
            id: descriptionText
            font.pixelSize: Theme.fontSizeSmall
            text: restaurant.comment
            wrapMode: Text.WordWrap
            color: Theme.primaryColor

            anchors {
                left: parent.left
                right: parent.right
                top: detailsCollapsible.bottom
                margins: Theme.paddingLarge
            }
        }
        VerticalScrollDecorator {}

    }
}

