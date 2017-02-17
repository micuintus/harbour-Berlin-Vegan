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

import "../components-generic/OpeningHoursModelAlgorithms.js" as OpeningHoursModelAlgorithms
import "../components-generic/VenueDescriptionAlgorithms.js" as PropertyStrings
import "../components-generic"

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
                            //% "Opening hours"
                text: qsTrId("id-opening-hours")
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
                      //% "Food details"
            text: qsTrId("id-food-details")
            id: foodDetailsHeader
        }

        DetailItem {
                                   //% "Category"
            label: qsTrId("id-vegan-venue-category")
            value: PropertyStrings.restaurantCategory(restaurant.vegan)
        }

        DetailItem {
                   //% "Cert. organic offers"
            label: qsTrId("id-organic")
            value: PropertyStrings.defaultBooleanProperty(restaurant.organic)
        }

        DetailItem {
                         //% "Gluten-free options"
            label: qsTrId("id-gluten-free")
            value: PropertyStrings.defaultBooleanProperty(restaurant.glutenFree)
        }


        SectionHeader {
                        //% "Accessibility"
            text: qsTrId("id-accessibility")
        }

        DetailItem {
                         //% "Wheelchair-friendly"
            label: qsTrId("id-wheelchair")
            value: PropertyStrings.defaultBooleanProperty(restaurant.handicappedAccessible)
        }

        DetailItem {
              //% "Wheelchair-accessible WC"
            label: qsTrId("id-wheelchair-wc")
            value: PropertyStrings.defaultBooleanProperty(restaurant.handicappedAccessibleWc)
        }

        DetailItem {
                         //% "High chair"
            label: qsTrId("id-high-chair")
            value: PropertyStrings.defaultBooleanProperty(restaurant.handicappedAccessibleWc)
        }

        DetailItem {
                         //% "Dogs allowed"
            label: qsTrId("id-dogs-allowed")
            value: PropertyStrings.defaultBooleanProperty(restaurant.dogs)
        }

        SectionHeader {
                        //% "Venue features"
            text: qsTrId("id-venue-features")
        }

        DetailItem {
                         //% "WiFi"
            label: qsTrId("id-wifi")
            value: PropertyStrings.defaultBooleanProperty(restaurant.wlan)
        }

        DetailItem {
                   //% "Seats outdoor"
            label: qsTrId("id-outdoor-seats")
            value: PropertyStrings.seatProperty(restaurant.seatsOutdoor)
        }

        DetailItem {
                   //% "Seats indoor"
            label: qsTrId("id-indoor-seats")
            value: PropertyStrings.seatProperty(restaurant.seatsIndoor)
        }

        DetailItem {
                         //% "Catering"
            label: qsTrId("id-catering")
            value: PropertyStrings.defaultBooleanProperty(restaurant.catering)
        }

        DetailItem {
                         //% "Delivery service"
            label: qsTrId("id-delivery")
            value: PropertyStrings.defaultBooleanProperty(restaurant.delivery)
        }
    }
}

