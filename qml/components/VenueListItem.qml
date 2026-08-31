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

import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.ui 1.0 as BVApp

import harbour.berlin.vegan 1.0

BVApp.ListItem {
    id: delegate

    property alias distanceText: distance.text

    // Cards carry the grouping, so the platform's row divider would double up.
    dividerVisible: false

    readonly property real unit: BVApp.Theme.gridUnit
    readonly property real bodySize: BVApp.Theme.fontSizeBody
    // Only the curated berlin-vegan.de venues carry photos; the ~2300 OSM ones
    // do not, so the thumbnail has to read as deliberate without one.
    readonly property bool hasPhoto: typeof model.pictures !== "undefined"
                                     && model.pictures.length > 0

    contentHeight: card.height + unit * BVApp.BrandTokens.snugUnits

    Rectangle {
        id: card

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: unit * BVApp.BrandTokens.snugUnits
            rightMargin: unit * BVApp.BrandTokens.snugUnits
            topMargin: unit * BVApp.BrandTokens.tightUnits
        }
        height: unit * BVApp.BrandTokens.thumbUnits + unit * BVApp.BrandTokens.snugUnits
        radius: unit * BVApp.BrandTokens.radiusCardUnits
        color: delegate.highlighted ? BVApp.BrandTokens.greenSoft
                                    : BVApp.BrandTokens.surface
        border.width: 1
        border.color: BVApp.BrandTokens.hairline

        // -- Thumbnail --------------------------------------------------------
        Rectangle {
            id: thumb
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: unit * BVApp.BrandTokens.snugUnits
            }
            width: unit * BVApp.BrandTokens.thumbUnits
            height: width
            visible: unit * BVApp.BrandTokens.thumbUnits > 0
            radius: unit * BVApp.BrandTokens.radiusChipUnits
            color: BVApp.BrandTokens.greenSoft
            clip: true

            Text {
                anchors.centerIn: parent
                visible: photo.status !== Image.Ready
                text: model.name.length > 0 ? model.name.charAt(0).toUpperCase() : "?"
                color: BVApp.BrandTokens.green
                font.pixelSize: BVApp.BrandTokens.title(bodySize)
                font.weight: BVApp.BrandTokens.weightMedium
            }

            Image {
                id: photo
                anchors.fill: parent
                visible: status === Image.Ready
                source: delegate.hasPhoto ? model.pictures[0].url : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        // -- Trailing: distance only -------------------------------------------
        // Open/closed rides on the address line instead of its own column:
        // reserving width for "closed now" on every card, when only some are
        // closed, is what squeezed the venue name.
        BVApp.Label {
            id: distance
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: unit * BVApp.BrandTokens.snugUnits
            }
            color: BVApp.BrandTokens.inkMuted
            font.pixelSize: BVApp.BrandTokens.caption(bodySize)
            horizontalAlignment: Text.AlignRight
        }

        // -- Name, veg chip, address ------------------------------------------
        Column {
            anchors {
                left: thumb.right
                right: distance.left
                verticalCenter: parent.verticalCenter
                leftMargin: unit * BVApp.BrandTokens.snugUnits
                rightMargin: unit * BVApp.BrandTokens.snugUnits
            }
            spacing: unit * BVApp.BrandTokens.tightUnits

            Item {
                width: parent.width
                height: nameLabel.implicitHeight

                BVApp.Label {
                    id: nameLabel
                    anchors {
                        left: parent.left
                        right: vegChip.visible ? vegChip.left : parent.right
                        rightMargin: vegChip.visible ? unit * BVApp.BrandTokens.tightUnits : 0
                        verticalCenter: parent.verticalCenter
                    }
                    text: model.name
                    color: BVApp.BrandTokens.ink
                    font.pixelSize: BVApp.BrandTokens.title(bodySize)
                    font.weight: BVApp.BrandTokens.weightMedium
                    truncationMode: TruncationMode.Fade
                }

                Rectangle {
                    id: vegChip
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: model.vegan >= VenueModel.Vegetarian
                    width: vegLabel.implicitWidth + unit * BVApp.BrandTokens.snugUnits
                    height: vegLabel.implicitHeight + unit * BVApp.BrandTokens.tightUnits
                    radius: height / 2
                    color: BVApp.Theme.vegTypeColor(model.vegan)
                    // Uncurated OSM entries assert less about their veg status.
                    opacity: (typeof model.dataSource !== "undefined"
                              && model.dataSource === "bv") ? 1.0 : 0.55

                    BVApp.Label {
                        id: vegLabel
                        anchors.centerIn: parent
                        text: model.vegan === VenueModel.Vegan
                                    //% "vegan"
                                    ? qsTrId("id-tag-vegan")
                                    //% "veggie"
                                    : qsTrId("id-tag-vegetarian")
                        color: "white"
                        font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                        font.weight: BVApp.BrandTokens.weightMedium
                    }
                }
            }

            Item {
                width: parent.width
                height: streetLabel.implicitHeight

                BVApp.Label {
                    id: stateLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !model.open || model.closesSoon
                                //% "closed now"
                    text: !model.open ? qsTrId("id-venue-closed")
                                //% "closes soon"
                                      : qsTrId("id-venue-closes-soon")
                    color: model.open ? BVApp.BrandTokens.warning
                                      : BVApp.BrandTokens.inkFaint
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                    font.weight: BVApp.BrandTokens.weightMedium
                }

                BVApp.Label {
                    id: separatorDot
                    anchors.left: stateLabel.right
                    anchors.leftMargin: unit * BVApp.BrandTokens.tightUnits
                    anchors.verticalCenter: parent.verticalCenter
                    visible: stateLabel.visible
                    text: "·"
                    color: BVApp.BrandTokens.inkFaint
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                }

                BVApp.Label {
                    id: streetLabel
                    anchors {
                        left: stateLabel.visible ? separatorDot.right : parent.left
                        right: parent.right
                        leftMargin: stateLabel.visible ? unit * BVApp.BrandTokens.tightUnits : 0
                        verticalCenter: parent.verticalCenter
                    }
                    text: model.street
                    color: BVApp.BrandTokens.inkMuted
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                    truncationMode: TruncationMode.Fade
                }
            }
        }
    }
}
