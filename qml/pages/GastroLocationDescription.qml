import QtQuick 2.2
import Sailfish.Silica 1.0
import QtPositioning 5.2


import "../components/OpeningHoursModelAlgorithms.js" as OpeningHoursModelAlgorithms
import "../components/GastroLocationDescriptionAlgorithms.js" as PropertyStrings
import "../components"

Page {

    id: page


    property var restaurant

    SilicaFlickable {
        id: flicka
        anchors.fill: parent
        readonly property real nonDescriptionHeaderHeight: locationheader.height + icontoolbar.height
        contentHeight: nonDescriptionHeaderHeight + longdescriptiontext.height + detailscollapsible.height
        property real scrolledUpRatio: 1 - (contentY / nonDescriptionHeaderHeight)

        VerticalScrollDecorator {}

        GastroLocationDescriptionHeader {
            id: locationheader
            name: restaurant.name
            street: restaurant.street
            pictures: restaurant.pictures
            restaurantCoordinate: QtPositioning.coordinate(restaurant.latCoord, restaurant.longCoord)

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
            id: icontoolbar
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
            id: detailscollapsible

            collapsedHeight: openinghourslistview.contentHeight
            expandedHeight: openinghours.implicitHeight

            anchors {
                left: parent.left
                right: parent.right
                top: icontoolbar.bottom
            }

            contentItem: Column {
                id: openinghours
                anchors.fill: parent

                SilicaListView {

                    id: openinghourslistview
                    height: contentHeight

                    header: SectionHeader {
                        text: qsTr("Opening hours")
                    }

                    width: parent.width

                    interactive: false

                    model: OpeningHoursModel {
                        id: openinghoursmodel
                        restaurant: page.restaurant

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

        Label {
            id: longdescriptiontext
            font.pixelSize: Theme.fontSizeSmall
            text: restaurant.comment
            wrapMode: Text.WordWrap
            color: Theme.primaryColor

            anchors {
                left: parent.left
                right: parent.right
                top: detailscollapsible.bottom
                margins: Theme.paddingLarge
            }
        }
    }
}

