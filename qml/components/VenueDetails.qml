import QtQuick 2.2
import Sailfish.Silica 1.0

import "../components/OpeningHoursModelAlgorithms.js" as OpeningHoursModelAlgorithms
import "../components/VenueDescriptionAlgorithms.js" as PropertyStrings
import "../components"

Item {

    id: venueDetails
    property var restaurant
    property alias collapsedHeight : openinghourslistview.height // + foodDetailsHeader.height
    property alias expandedHeight  : venueDetailsColum.implicitHeight

    Column {

        id: venueDetailsColum

        anchors.fill: parent

        ListView {

            id: openinghourslistview

            header: SectionHeader {
                text: qsTr("Opening hours")
            }

            width: parent.width
            height: contentHeight

            interactive: false

            model: OpeningHoursModel {
                id: openinghoursmodel
                restaurant: venueDetails.restaurant

                Component.onCompleted: OpeningHoursModelAlgorithms.condenseOpeningHoursModel(openinghoursmodel)
            }

            delegate: DetailItem {
                label: model.day
                value: model.hours
            }
        }

        SectionHeader {
            text: qsTr("Food details")
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

