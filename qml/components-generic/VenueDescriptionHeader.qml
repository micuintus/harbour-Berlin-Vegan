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


Item {

    property string name
    property string street
    property var restaurantCoordinate
    property var pictures
    property var pictureAvailable: typeof pictures !== "undefined"
                                       && pictures.length !== 0
    property var positionSource
    property real shrinkHeightBy


    Image {
        id: image

        source: pictureAvailable
                ? pictures[0].url
                : ""

        fillMode: Image.PreserveAspectCrop

        height: Math.max(parent.height - shrinkHeightBy,0)
        width: parent.width

        // This eads to the effect that the image is being cropped
        // from both bottom and top by half a pixel per shrinkHeightBy
        y: shrinkHeightBy
    }

    Rectangle {
        property int xMargin: 10
        property int yMargin: 7
        // v-play: TypeError: Cannot read property 'x' of undefined
        x: nameLabel.extraContent.x + nameLabel.extraContent.width - xMargin
        y: nameLabel.y + nameLabel.childrenRect.y - yMargin - shrinkHeightBy * 0.1
        height: nameLabel.childrenRect.height + yMargin*2
        // v-play: TypeError: Cannot read property 'width' of undefined
        width: (nameLabel.childrenRect.width - nameLabel.extraContent.width) + xMargin*2
        radius: 5
        color: BVApp.Theme.highlightDimmerColor
        opacity: 0.6
    }

    PageHeader {
        id: nameLabel
        readonly property int initalY: 100

        title : name
        y: initalY + shrinkHeightBy * 0.5
    }

    Rectangle {
        anchors {
            top: streetLabel.top
            topMargin: -BVApp.Theme.paddingMedium
            left: image.left
            right: image.right
            bottom: image.bottom
        }

        color: BVApp.Theme.highlightDimmerColor

        // relative to parent opacity!
        opacity: BVApp.Platform.isSailfish ? 0.6 : 1
        visible: !BVApp.Platform.isSailfish || pictureAvailable
    }

    Label {
        id: streetLabel
        text: street
        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
        color: BVApp.Platform.isSailfish ? BVApp.Theme.highlightColor : BVApp.Theme.secondaryColor
        truncationMode: TruncationMode.Fade

        anchors {
            left: image.left
            right: distanceLabel.left
            margins: BVApp.Theme.paddingLarge
        }

        y: parent.height - height
    }

    Label {
        id: distanceLabel
        text: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods
              ? BVApp.DistanceAlgorithms.humanReadableDistanceString(positionSource.position.coordinate,
                                                               restaurantCoordinate)
              : ""
        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
        color: BVApp.Theme.highlightColor

        anchors {
            right: parent.right
            margins:  BVApp.Theme.paddingLarge
        }

        y: parent.height - height
    }
}

