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

import "../components/OpeningHoursModelAlgorithms.js" as OpeningHoursModelAlgorithms
import "../components/VenueDescriptionAlgorithms.js" as PropertyStrings
import "../components"

Item {

    id: venueDetails
    property var restaurant
    readonly property real collapsedHeight : openingHourListView.height + foodDetailsHeader.height
    readonly property real expandedHeight  : venueDetailsColum.implicitHeight

    Column {

        id: venueDetailsColum

        anchors.fill: parent

        ListView {

            id: openingHourListView

            header: SectionHeader {
                text: qsTr("Opening hours")
            }

            width: parent.width
            height: contentItem.height

            interactive: false

            model: OpeningHoursModel {
                id: openingHoursModel
                restaurant: venueDetails.restaurant

                Component.onCompleted: OpeningHoursModelAlgorithms.condenseOpeningHoursModel(openingHoursModel)
            }

            delegate: DetailItem {
                label: model.day
                value: model.hours
            }
        }

        SectionHeader {
            text: qsTr("Food details")
            id: foodDetailsHeader
        }

        DetailItem {
            label: qsTr("Category")
            value: PropertyStrings.restaurantCategory(restaurant.vegan)
        }

        DetailItem {
            label: qsTr("Cert. organic offers")
            value: PropertyStrings.defaultBooleanProperty(restaurant.organic)
        }

        DetailItem {
            label: qsTr("Gluten-free options")
            value: PropertyStrings.defaultBooleanProperty(restaurant.glutenFree)
        }


        SectionHeader {
            text: qsTr("Accessibility")
        }

        DetailItem {
            label: qsTr("Wheelchair-friendly")
            value: PropertyStrings.defaultBooleanProperty(restaurant.handicappedAccessible)
        }

        DetailItem {
            label: qsTr("Wheelchair-accessible WC")
            value: PropertyStrings.defaultBooleanProperty(restaurant.handicappedAccessibleWc)
        }

        DetailItem {
            label: qsTr("High chair")
            value: PropertyStrings.defaultBooleanProperty(restaurant.handicappedAccessibleWc)
        }

        DetailItem {
            label: qsTr("Dogs allowed")
            value: PropertyStrings.defaultBooleanProperty(restaurant.dogs)
        }

        SectionHeader {
            text: qsTr("Venue features")
        }

        DetailItem {
            label: qsTr("WiFi")
            value: PropertyStrings.defaultBooleanProperty(restaurant.wlan)
        }

        DetailItem {
            label: qsTr("Seats outdoor")
            value: PropertyStrings.seatProperty(restaurant.seatsOutdoor)
        }

        DetailItem {
            label: qsTr("Seats indoor")
            value: PropertyStrings.seatProperty(restaurant.seatsIndoor)
        }

        DetailItem {
            label: qsTr("Catering")
            value: PropertyStrings.defaultBooleanProperty(restaurant.catering)
        }

        DetailItem {
            label: qsTr("Delivery service")
            value: PropertyStrings.defaultBooleanProperty(restaurant.delivery)
        }
    }
}

