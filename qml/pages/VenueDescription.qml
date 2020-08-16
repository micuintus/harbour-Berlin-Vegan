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
import QtPositioning 5.2

import harbour.berlin.vegan 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp


BVApp.Page {

    id: page
    title: restaurant.name

    property var restaurant
    property var positionSource
    readonly property bool isGastroVenue: restaurant.venueType === VenueModel.Gastro


    SilicaFlickable {
        id: flicka
        anchors.fill: parent
        contentHeight: tellWaiter.y + tellWaiter.height + tellWaiter.anchors.topMargin

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
            }
        }

        Item {
            id: underHeaderBar

            opacity: flicka.scrolledUpRatio
            width: parent.width
            height: streetLabel.height

            anchors {
                top:    BVApp.Platform.isFelgo ?
                          locationHeader.bottom
                        : undefined
                bottom: BVApp.Platform.isSailfish ?
                          locationHeader.bottom
                        : undefined

                topMargin: BVApp.Theme.paddingMedium
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

            collapsed: isGastroVenue
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
                isGastroVenue: page.isGastroVenue
                anchors.fill: parent
            }
        }

        Separator {
            id: separator

            visible: BVApp.Platform.isFelgo

            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: BVApp.Theme.dividerColor
            height: BVApp.Theme.dividerHeight

            anchors {
                left: shortComment.left
                right: shortComment.right
                top: detailsCollapsible.bottom
            }
        }


        BVApp.VenueSubTypeTagCloud {
            id: venueSubTypeTagCloud
            restaurant: page.restaurant
            venueSubTypeDefinitions:
                isGastroVenue ?
                    BVApp.VenueSubTypeDefinitions.gastroVenueSubTypes
                  : BVApp.VenueSubTypeDefinitions.shopVenueSubTypes

            anchors {
                left: parent.left
                right: parent.right
                top: BVApp.Platform.isFelgo ?
                       separator.bottom
                     : detailsCollapsible.bottom

                topMargin:    BVApp.Platform.isSailfish ?
                                BVApp.Theme.paddingSmall
                              : BVApp.Theme.paddingMedium
                leftMargin:   BVApp.Theme.horizontalPageMargin
                rightMargin:  BVApp.Theme.horizontalPageMargin
            }
        }

        Label {
            id: shortComment

            TextMetrics {
                id: shortCommentTextMetrics
                font.family: shortComment.font.family
                font.pixelSize: BVApp.Theme.fontSizeSmall

                elide: Text.ElideNone
                text: Qt.locale().name.toLowerCase().indexOf("de") === 0 ? // startsWith() was introduced in Qt 5.8 and Sailfish is currently running 5.6
                          restaurant.comment :
                          restaurant.commentEnglish
            }

            property bool showShortCommentLeftOfTags:
                shortCommentTextMetrics.width + venueSubTypeTagCloud.implicitWidth + BVApp.Theme.horizontalPageMargin
                <= parent.width -  2 * BVApp.Theme.horizontalPageMargin

            font.pixelSize: BVApp.Theme.fontSizeSmall
            text: shortCommentTextMetrics.text
            wrapMode: Text.WordWrap
            color: BVApp.Theme.primaryColor

            anchors {
                left: parent.left
                right: parent.right
                top:  showShortCommentLeftOfTags ?
                         venueSubTypeTagCloud.top
                       : venueSubTypeTagCloud.bottom

                topMargin: showShortCommentLeftOfTags ? 0 : BVApp.Theme.paddingMedium
                leftMargin:   BVApp.Theme.horizontalPageMargin
                rightMargin:  BVApp.Theme.horizontalPageMargin
            }
        }

        VenueMapWidget {
            id: map

            venueCoordinate: QtPositioning.coordinate(restaurant.latCoord, restaurant.longCoord)
            vegan: restaurant.vegan
            positionSource: page.positionSource

            height: BVApp.Theme.mapHeight

            anchors {
                left: shortComment.left
                right: shortComment.right
                top: shortComment.showShortCommentLeftOfTags ?
                         venueSubTypeTagCloud.bottom
                       : shortComment.bottom

                topMargin:  BVApp.Platform.isSailfish ?
                                BVApp.Theme.paddingLarge
                              : BVApp.Theme.paddingMedium
            }
        }


        Label {
            id: review

            visible: typeof restaurant.review !== "undefined"

            font.pixelSize: BVApp.Theme.fontSizeSmall
            text: visible ? restaurant.review : ""
            wrapMode: Text.WordWrap
            color: BVApp.Theme.primaryColor

            anchors {
                left: parent.left
                right: parent.right
                top: map.bottom

                topMargin:    BVApp.Theme.paddingLarge
                leftMargin:   BVApp.Theme.horizontalPageMargin
                rightMargin:  BVApp.Theme.horizontalPageMargin
            }
        }

        Label {
            id: tellWaiter

            visible: isGastroVenue

            anchors {
                left: parent.left
                right: parent.right
                top: review.visible ? review.bottom : map.bottom

                topMargin:    BVApp.Theme.paddingLarge
                leftMargin:   BVApp.Theme.horizontalPageMargin
                rightMargin:  BVApp.Theme.horizontalPageMargin
            }

            font {
                pixelSize: BVApp.Theme.fontSizeSmall
                italic: true
            }

            wrapMode: Text.WordWrap
            color: BVApp.Theme.primaryColor

            //% "Please tell the waiter/owner that you found their venue via the Berlin-Vegan app. The significance of being listed in a database like this is often underestimated. Thanks for the help!"
            text: qsTrId("id-venue-please-tell-waiter")
        }
    }
}

