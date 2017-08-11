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

import BerlinVegan.components.generic 1.0 as BVApp
import BerlinVegan.components.platform 1.0 as BVApp

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

            header: BVApp.SectionHeader {
                            //% "Opening hours"
                text: qsTrId("id-opening-hours")
                icon: BVApp.Theme.iconFor("schedule")
            }

            width: parent.width
            height: contentItem.height

            interactive: false

            model: BVApp.OpeningHoursModel {
                id: openingHoursModel
                restaurant: venueDetails.restaurant

                Component.onCompleted: BVApp.OpeningHoursModelAlgorithms.condenseOpeningHoursModel(openingHoursModel)
            }

            delegate: DetailItem {
                label: model.day
                value: model.hours
            }
        }

        BVApp.SectionHeader {
                      //% "Food details"
            text: qsTrId("id-food-details")
            icon: BVApp.Theme.iconFor("details")
            id: foodDetailsHeader
        }

        DetailItem {
                                   //% "Category"
            label: qsTrId("id-vegan-venue-category")
            value: BVApp.VenueDescriptionAlgorithms.restaurantCategory(restaurant.vegan)
        }

        DetailItem {
                   //% "Organic products"
            label: qsTrId("id-organic")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.organic)
        }

        DetailItem {
                         //% "Gluten-free options"
            label: qsTrId("id-gluten-free")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.glutenFree)
        }


        BVApp.SectionHeader {
                        //% "Accessibility"
            text: qsTrId("id-accessibility")
            icon: BVApp.Theme.iconFor("accessible")
        }

        DetailItem {
                         //% "Wheelchair-friendly"
            label: qsTrId("id-wheelchair")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.handicappedAccessible)
        }

        DetailItem {
              //% "Wheelchair-accessible WC"
            label: qsTrId("id-wheelchair-wc")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.handicappedAccessibleWc)
        }

        DetailItem {
                         //% "High chair"
            label: qsTrId("id-high-chair")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.childChair)
        }

        DetailItem {
                         //% "Dogs allowed"
            label: qsTrId("id-dogs-allowed")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.dog)
        }

        BVApp.SectionHeader {
                        //% "Venue features"
            text: qsTrId("id-venue-features")
            icon: BVApp.Theme.iconFor("more_vert")
        }

        DetailItem {
                         //% "WiFi"
            label: qsTrId("id-wifi")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.wlan)
        }

        DetailItem {
                   //% "Seats outdoor"
            label: qsTrId("id-outdoor-seats")
            value: BVApp.VenueDescriptionAlgorithms.seatProperty(restaurant.seatsOutdoor)
        }

        DetailItem {
                   //% "Seats indoor"
            label: qsTrId("id-indoor-seats")
            value: BVApp.VenueDescriptionAlgorithms.seatProperty(restaurant.seatsIndoor)
        }

        DetailItem {
                         //% "Catering"
            label: qsTrId("id-catering")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.catering)
        }

        DetailItem {
                         //% "Delivery service"
            label: qsTrId("id-delivery")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.delivery)
        }
    }
}

