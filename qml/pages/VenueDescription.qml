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
import QtPositioning 5.2
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp


BVApp.Page {

    id: page
    title: restaurant.name

    property var restaurant
    property var positionSource

    SilicaFlickable {
        id: flicka
        anchors.fill: parent
        contentHeight: descriptionText.y + descriptionText.height + BVApp.Theme.paddingLarge
        readonly property real nonDescriptionHeaderHeight: locationHeader.height
                                                          + underHeaderBar.height
                                                          + iconToolBar.height
        property real scrolledUpRatio: 1 - (contentY / nonDescriptionHeaderHeight)

        BVApp.VenueDescriptionHeader {
            id: locationHeader
            name: restaurant.name
            pictures: restaurant.pictures
            positionSource: page.positionSource

            opacity: flicka.scrolledUpRatio
            height: BVApp.Platform.isSailfish ?
                      page.height / 2.6
                    : page.height / 3
            shrinkHeightBy: flicka.contentY

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top

                bottomMargin: BVApp.Theme.paddingMedium
            }
        }

        Item {
            id: underHeaderBar

            opacity: flicka.scrolledUpRatio
            width: parent.width
            height: streetLabel.height

            anchors {
                top:    BVApp.Platform.isVPlay ?
                          locationHeader.bottom
                        : undefined
                bottom: BVApp.Platform.isSailfish ?
                          locationHeader.bottom
                        : undefined

                topMargin: BVApp.Theme.paddingMedium
                bottomMargin: BVApp.Theme.paddingMedium
            }

            Label {
                id: streetLabel
                text: restaurant.street
                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                color: BVApp.Platform.isSailfish ?
                         BVApp.Theme.highlightColor
                       : BVApp.Theme.secondaryColor
                truncationMode: TruncationMode.Fade

                anchors {
                    top: parent.top
                    left: parent.left
                    right: distanceLabel.left

                    leftMargin:  BVApp.Theme.horizontalPageMargin
                    rightMargin: BVApp.Theme.paddingSmall
                }
            }

            Label {
                id: distanceLabel
                text: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods
                      ? BVApp.DistanceAlgorithms.humanReadableDistanceString(positionSource.position.coordinate,
                        QtPositioning.coordinate(restaurant.latCoord, restaurant.longCoord))
                      : ""
                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                color: BVApp.Theme.highlightColor
                horizontalAlignment: Text.AlignRight

                anchors {
                    top: parent.top
                    right: parent.right

                    rightMargin: BVApp.Theme.horizontalPageMargin
                }
            }
        }

        BVApp.IconToolBar {
            id: iconToolBar
            restaurant: page.restaurant

            anchors {
                left: parent.left
                right: parent.right
                top: underHeaderBar.bottom

                leftMargin: BVApp.Theme.horizontalPageMargin
                rightMargin: BVApp.Theme.horizontalPageMargin
                topMargin: BVApp.Theme.paddingMedium
            }

            opacity: flicka.scrolledUpRatio
        }

        BVApp.CollapsibleItem {
            id: detailsCollapsible

            collapsedHeight: venueDetails.collapsedHeight
            expandedHeight: venueDetails.expandedHeight + BVApp.Theme.paddingLarge

            anchors {
                left: parent.left
                right: parent.right
                top: iconToolBar.bottom

            }

            contentItem: BVApp.VenueDetails {
                id: venueDetails
                restaurant: page.restaurant
                anchors.fill: parent
            }
        }

        Separator {
            id: separator

            visible: BVApp.Platform.isVPlay

            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: BVApp.Theme.dividerColor
            height: BVApp.Theme.dividerHeight

            anchors {
                left: descriptionText.left
                right: descriptionText.right
                top: detailsCollapsible.bottom
            }
        }

        Label {
            id: descriptionText
            font.pixelSize: BVApp.Theme.fontSizeSmall
            text: restaurant.comment
            wrapMode: Text.WordWrap
            color: BVApp.Theme.primaryColor

            anchors {
                left: parent.left
                right: parent.right
                top: BVApp.Platform.isVPlay ?
                       separator.bottom
                     : detailsCollapsible.bottom

                topMargin:    BVApp.Platform.isSailfish ?
                                BVApp.Theme.paddingSmall
                              : BVApp.Theme.paddingLarge
                bottomMargin: BVApp.Theme.paddingLarge
                leftMargin:   BVApp.Theme.horizontalPageMargin
                rightMargin:  BVApp.Theme.horizontalPageMargin
            }
        }
    }
}

