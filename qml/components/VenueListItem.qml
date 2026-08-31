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
    property bool showVegCategory: true

    // Cards carry the grouping, so the platform's row divider would double up.
    dividerVisible: true

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
        radius: delegate.highlighted ? unit * BVApp.BrandTokens.radiusCardUnits : 0
        color: delegate.highlighted ? BVApp.BrandTokens.greenSoft
                                    : "transparent"
        // Cards separate by sitting on the canvas; an outline as well makes
        // every row read as a sticker.
        border.width: 0

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
                opacity: 0.55
                font.pixelSize: bodySize
                font.weight: BVApp.BrandTokens.weightNormal
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

        // -- Content: two lines, each carrying its own left and right cell ----
        // Keeping both cells inside the line means the columns share a
        // baseline grid; anchoring across the hierarchy silently does nothing.
        Column {
            anchors {
                left: thumb.right
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: unit * BVApp.BrandTokens.baseUnits
                rightMargin: unit * BVApp.BrandTokens.baseUnits
            }
            spacing: unit * BVApp.BrandTokens.tightUnits

            Item {
                width: parent.width
                height: nameLabel.implicitHeight

                BVApp.Label {
                    id: vegChip
                    anchors.right: parent.right
                    anchors.baseline: nameLabel.baseline
                    visible: delegate.showVegCategory
                             && model.vegan >= VenueModel.Vegetarian
                    text: model.vegan === VenueModel.Vegan
                                //% "vegan"
                                ? qsTrId("id-tag-vegan")
                                //% "veggie"
                                : qsTrId("id-tag-vegetarian")
                    color: model.vegan === VenueModel.Vegan ? BVApp.BrandTokens.vegan
                                                            : BVApp.BrandTokens.vegetarian
                    // Uncurated OSM entries assert less about their veg status.
                    opacity: (typeof model.dataSource !== "undefined"
                              && model.dataSource === "bv") ? 1.0 : 0.6
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: BVApp.BrandTokens.metaTracking
                }

                BVApp.Label {
                    id: nameLabel
                    anchors {
                        left: parent.left
                        right: vegChip.visible ? vegChip.left : parent.right
                        rightMargin: vegChip.visible ? unit * BVApp.BrandTokens.baseUnits : 0
                        verticalCenter: parent.verticalCenter
                    }
                    text: model.name
                    color: BVApp.BrandTokens.ink
                    font.pixelSize: BVApp.BrandTokens.title(bodySize)
                    truncationMode: TruncationMode.Fade
                }
            }

            Item {
                width: parent.width
                height: streetLabel.implicitHeight

                BVApp.Label {
                    id: distance
                    anchors.right: parent.right
                    anchors.baseline: streetLabel.baseline
                    color: BVApp.BrandTokens.inkMuted
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                }

                BVApp.Label {
                    id: newLabel
                    anchors.left: parent.left
                    anchors.baseline: streetLabel.baseline
                    visible: model.isNew
                                //% "new"
                    text: qsTrId("id-tag-new")
                    color: BVApp.BrandTokens.vegan
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: BVApp.BrandTokens.metaTracking
                }

                BVApp.Label {
                    id: newDot
                    anchors.left: newLabel.right
                    anchors.leftMargin: unit * BVApp.BrandTokens.tightUnits
                    anchors.baseline: streetLabel.baseline
                    visible: newLabel.visible
                    text: "\u00b7"
                    color: BVApp.BrandTokens.inkFaint
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                }

                BVApp.Label {
                    id: stateLabel
                    anchors.left: newLabel.visible ? newDot.right : parent.left
                    anchors.leftMargin: newLabel.visible ? unit * BVApp.BrandTokens.tightUnits : 0
                    anchors.baseline: streetLabel.baseline
                    visible: !model.open || model.closesSoon
                                //% "closed now"
                    text: !model.open ? qsTrId("id-venue-closed")
                                //% "closes soon"
                                      : qsTrId("id-venue-closes-soon")
                    color: model.open ? BVApp.BrandTokens.warning
                                      : BVApp.BrandTokens.inkFaint
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                }

                BVApp.Label {
                    id: separatorDot
                    anchors.left: stateLabel.right
                    anchors.leftMargin: unit * BVApp.BrandTokens.tightUnits
                    anchors.baseline: streetLabel.baseline
                    visible: stateLabel.visible
                    text: "\u00b7"
                    color: BVApp.BrandTokens.inkFaint
                    font.pixelSize: BVApp.BrandTokens.caption(bodySize)
                }

                BVApp.Label {
                    id: streetLabel
                    anchors {
                        left: stateLabel.visible ? separatorDot.right
                                                 : (newLabel.visible ? newDot.right : parent.left)
                        right: distance.left
                        leftMargin: (stateLabel.visible || newLabel.visible)
                                        ? unit * BVApp.BrandTokens.tightUnits : 0
                        rightMargin: unit * BVApp.BrandTokens.baseUnits
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
