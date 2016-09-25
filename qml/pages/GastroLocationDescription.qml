import QtQuick 2.2
import Sailfish.Silica 1.0

import QtPositioning 5.2

import "../components/distance.js" as Distance
import "../components/OpeningHoursModelAlgorithms.js" as OpeningHoursModelAlgorithms
import "../components"

Page {

    id: page


    PositionSource {
        id: positionSource
    }

    property var restaurant

    SilicaFlickable {
        id: flicka
        anchors.fill: parent
        property real nonDescriptionHeaderHeight: image.initalHeight + icontoolbar.height
        contentHeight: nonDescriptionHeaderHeight + longdescriptiontext.height + detailscollapsible.height
        property real scrolledUpRatio: 1 - (contentY / nonDescriptionHeaderHeight)

        VerticalScrollDecorator {}

        Image {
            id: image

            source: typeof restaurant["pictures"] !== "undefined"
                    ? restaurant.pictures[0].url
                    : ""
            property real initalHeight: page.height/3

            fillMode: Image.PreserveAspectCrop

            height: Math.max(initalHeight - flicka.contentY,0)
            y: flicka.contentY
            opacity: flicka.scrolledUpRatio
        }

        Rectangle {
            property int xMargin: 10
            property int yMargin: 7
            property real initialOpacity: 0.6
            x: myheader.extraContent.x + myheader.extraContent.width - xMargin
            y: myheader.y + myheader.childrenRect.y - yMargin - flicka.contentY * 0.1
            height: myheader.childrenRect.height + yMargin*2
            width: (myheader.childrenRect.width - myheader.extraContent.width) + xMargin*2
            radius: 5
            color: Theme.highlightDimmerColor
            opacity: initialOpacity  * flicka.scrolledUpRatio

        }

        PageHeader {
            id: myheader
            property int initalY: 100

            title : restaurant.name
            y: initalY  + flicka.contentY * 0.5
            opacity: flicka.scrolledUpRatio
        }

        Rectangle {
            anchors {
                top: streetLabel.top
                left: image.left
                right: image.right
                bottom: image.bottom
            }

            color: Theme.highlightDimmerColor
            opacity: 0.6 * flicka.scrolledUpRatio
        }

        Label {
            id: streetLabel
            text: restaurant.street
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
            truncationMode: TruncationMode.Fade

            anchors {
                left: image.left
                right: distance.left
                // top: image.bottom
                margins:  Theme.paddingLarge
            }

            opacity: flicka.scrolledUpRatio
            y: image.initalHeight - height // + Theme.paddingSmall
        }

        Label {
            id: distance
            text: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods
                  ? Distance.humanReadableDistanceString(positionSource.position.coordinate,
                                                         QtPositioning.coordinate(restaurant.latCoord, restaurant.longCoord))
                  : ""
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor

            anchors {
                right: parent.right
                // rightMargin: Theme.horizontalPageMargin
                margins:  Theme.paddingLarge
            }

            opacity: flicka.scrolledUpRatio
            y: image.initalHeight - height // + Theme.paddingSmall
        }

        IconToolBar {
            id: icontoolbar
            restaurant: page.restaurant

            anchors {
                left: parent.left
                right: parent.right
                top: streetLabel.bottom
                margins: Theme.paddingLarge

            }

            opacity: flicka.scrolledUpRatio
        }

        CollapsibleItem {
            id: detailscollapsible

            collapsedHeight: page.height / 6
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
                    height: openinghourslistview.contentHeight

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
                    value: {
                        switch(restaurant.vegan)
                        {
                            case 1: qsTr("omnivore"); break;
                            case 2: qsTr("omnivore \n(vegan declared)"); break;
                            case 3: qsTr("vegetarian"); break;
                            case 4: qsTr("vegetarian \n(vegan declared)"); break;
                            case 5: qsTr("100% vegan"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Cert. organic offers")
                    value: {
                        switch (restaurant.organic)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Gluten-free options")
                    value: {
                        switch (restaurant.glutenFree)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }
                SectionHeader {
                    text: qsTr("Accessibility")
                }


                DetailItem {
                    label: qsTr("Wheelchair-friendly")
                    value: {
                        switch (restaurant.handicappedAccessible)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Wheelchair-accessible WC")
                    value: {
                        switch (restaurant.handicappedAccessibleWc)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("High chair")
                    value: {
                        switch (restaurant.childChair)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Dogs allowed")
                    value: {
                        switch (restaurant.dog)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                SectionHeader {
                    text: qsTr("Venue features")
                }

                DetailItem {
                    label: qsTr("WiFi")
                    value: {
                        switch (restaurant.wlan)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Seats outdoor")
                    value: {
                        switch (restaurant.seatsOutdoor)
                        {
                            case -1: qsTr("unknown"); break;
                            case  0: qsTr("no"); break;
                            default: restaurant.seatsOutdoor; break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Seats indoor")
                    value: {
                        switch (restaurant.seatsIndoor)
                        {
                            case -1: qsTr("unknown"); break;
                            case  0: qsTr("no"); break;
                            default: restaurant.seatsIndoor; break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Catering")
                    value: {
                        switch (restaurant.catering)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
                }

                DetailItem {
                    label: qsTr("Delivery service")
                    value: {
                        switch (restaurant.delivery)
                        {
                            case 1: qsTr("yes"); break;
                            case 0: qsTr("no"); break;
                            default: qsTr("unknown"); break;
                        }
                    }
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

