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

import QtQuick 2.5
import Sailfish.Silica 1.0

import BerlinVegan.components.generic 1.0 as BVApp
import BerlinVegan.components.platform 1.0 as BVApp

import harbour.berlin.vegan 1.0

Item {

    id: venueDetails
    property var restaurant
    property bool isGastroVenue

    // internal
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

            model: restaurant.condensedOpeningHours

            delegate: BVApp.DetailItem {
                label: modelData["day"]
                value: modelData["hours"]
                fontWeight: modelData["current"] ?
                                Font.Bold
                              : Font.Normal
            }
        }

        Item {
            visible: openComment.visible
            height: BVApp.Theme.paddingSmall
            width: parent.width
        }

        Label {
            id: openComment

            visible: text != ""

            anchors {
                // As we cannot get hold of the last opening hours item easily,
                // we just go with the next detail item
                left: organic.left
                right: organic.right
                leftMargin: organic.leftMargin
                rightMargin: organic.rightMargin
            }

            text: if ((Qt.locale().name.toLowerCase().indexOf("de") === 0 || typeof restaurant.openCommentEnglish === "undefined")
                          && typeof restaurant.openComment !== "undefined")
                  {
                      return restaurant.openComment;
                  }
                  else if (typeof restaurant.openCommentEnglish !== "undefined")
                  {
                      return restaurant.openCommentEnglish;
                  }
                  else return "";

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignRight

            font {
                pixelSize: organic.fontSize
                italic: true
            }

            color: organic.valueColor
        }

        Item {
            visible: BVApp.Platform.isSailfish && openComment.visible
            height: BVApp.Theme.paddingLarge
            width: parent.width
        }

        BVApp.SectionHeader {
                     //% "Features"
            text: qsTrId("id-venue-features")
            icon: BVApp.Theme.iconFor("more_vert")
            // Summerize venue features for shops under one single header
            visible: !isGastroVenue // Section header always visible for shop venues, as venueCategory should be never unknown
        }

        BVApp.SectionHeader {
                     //% "Food details"
            text: qsTrId("id-food-details")
            icon: BVApp.Theme.iconFor("details")
            id: foodDetailsHeader
            // Summerize venue features for shops under one single header
            visible: isGastroVenue // Section header always visible for gastro venues, as venueCategory should be never unknown
        }

        BVApp.DetailItem {
            id: venueCategory
                      //% "Category"
            label: isGastroVenue ?
                       qsTrId("id-vegan-venue-category")
                     : qsTrId("id-filter-vegan-category")
            value: BVApp.VenueDescriptionAlgorithms.restaurantCategory(restaurant.vegan)
            visible: true // venueCategory should be never unknown
        }

        BVApp.DetailItem {
            id: organic
                      //% "Organic products"
            label: qsTrId("id-organic")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.organic)
            visible: !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.organic)
        }

        BVApp.DetailItem {
            id: breakfast
                      //% "Breakfast"
            label: qsTrId("id-breakfast")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.breakfast)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.breakfast)
        }

        BVApp.DetailItem {
            id: brunch
                      //% "Brunch"
            label: qsTrId("id-brunch")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.brunch)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.brunch)
        }

        BVApp.DetailItem {
            id: glutenFree
                      //% "Gluten-free options"
            label: qsTrId("id-gluten-free")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.glutenFree)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.glutenFree)
        }

        BVApp.SectionHeader {
                     //% "Accessibility"
            text: qsTrId("id-accessibility")
            icon: BVApp.Theme.iconFor("accessible")
            // Summerize venue features for shops under one single header
            visible: isGastroVenue && (wheelchairFriendly.visible || wheelchairAccessibleWc.visible || highChair.visible || dogsAllowed.visible)
        }

        BVApp.DetailItem {
            id: wheelchairFriendly
                      //% "Wheelchair-friendly"
            label: qsTrId("id-wheelchair")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.handicappedAccessible)
            visible: !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.handicappedAccessible)
        }

        BVApp.DetailItem {
            id: wheelchairAccessibleWc
                      //% "Wheelchair-accessible WC"
            label: qsTrId("id-wheelchair-wc")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.handicappedAccessibleWc)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.handicappedAccessibleWc)
        }

        BVApp.DetailItem {
            id: highChair
                      //% "High chair"
            label: qsTrId("id-high-chair")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.childChair)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.childChair)
        }

        BVApp.DetailItem {
            id: dogsAllowed
                      //% "Dogs allowed"
            label: qsTrId("id-dogs-allowed")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.dog)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.dog)
        }

        BVApp.SectionHeader {
                     //% "Further features"
            text: qsTrId("id-venue-more-features")
            icon: BVApp.Theme.iconFor("more_vert")
            // Summerize venue features for shops under one single header
            visible: isGastroVenue && (deliveryService.visible || catering.visible || wifi.visible || seatsOutdoor.visible || seatsIndoor.visible)
        }

        BVApp.DetailItem {
            id: deliveryService
                      //% "Delivery service"
            label: qsTrId("id-delivery")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.delivery)
            visible: !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.delivery)
        }

        BVApp.DetailItem {
            id: catering
                      //% "Catering"
            label: qsTrId("id-catering")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.catering)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.catering)
        }

        BVApp.DetailItem {
            id: wifi
                      //% "WiFi"
            label: qsTrId("id-wifi")
            value: BVApp.VenueDescriptionAlgorithms.defaultBooleanProperty(restaurant.wlan)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.wlan)
        }

        BVApp.DetailItem {
            id: seatsOutdoor
                      //% "Seats outdoor"
            label: qsTrId("id-outdoor-seats")
            value: BVApp.VenueDescriptionAlgorithms.seatProperty(restaurant.seatsOutdoor)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.seatsOutdoor)
        }

        BVApp.DetailItem {
            id: seatsIndoor
                      //% "Seats indoor"
            label: qsTrId("id-indoor-seats")
            value: BVApp.VenueDescriptionAlgorithms.seatProperty(restaurant.seatsIndoor)
            visible: isGastroVenue && !BVApp.VenueDescriptionAlgorithms.valueUnknown(restaurant.seatsIndoor)
        }
    }
}

