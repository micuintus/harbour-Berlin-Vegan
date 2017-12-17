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

import QtGraphicalEffects 1.0

import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

import "tinycolor.js" as TinyColor


Item {

    id: root

    property string name
    property string street
    property var restaurantCoordinate
    property var pictures
    property var pictureAvailable: typeof pictures !== "undefined"
                                       && pictures.length !== 0
    property var positionSource
    property real shrinkHeightBy


    BVApp.SwipeView {
        id: images

        anchors.fill: parent

        // '1' so we see the placeholder image
        model: pictureAvailable ? pictures.length : 1

        delegate: Image {

            source: pictureAvailable
                    ? pictures[index].url
                    : "qrc:/images/Platzhalter_v2_mitSchriftzug" + (BVApp.Platform.isSailfish ?
                                                                        "_alpha.png"
                                                                      : ".jpg")
            fillMode: Image.PreserveAspectCrop

            height: Math.max(root.height - shrinkHeightBy,0)
            width: root.width

            // This leads to the effect that the image is being cropped
            // from both bottom and top by half a pixel per shrinkHeightBy
            y: shrinkHeightBy
        }
    }

    BVApp.PageIndicator {
        visible: images.count > 1

        model: images.count
        currentIndex: images.currentIndex

        anchors.bottom: images.bottom
        anchors.bottomMargin: BVApp.Theme.pageIndicatorPadding
        anchors.horizontalCenter: parent.horizontalCenter
    }

    OpacityRampEffect {
        id: ramp
        enabled: BVApp.Platform.isSailfish
        anchors.fill: images
        sourceItem: images
        direction: BVApp.Theme.opacityRampTopToBottom
        offset: 0.54
        slope: 2.24
    }

    Colorize {
        readonly property color srcColor: BVApp.Theme.highlightColor
        hue: TinyColor.rgbToHsl(srcColor.r, srcColor.g, srcColor.b).h
        source: ramp
        visible: !pictureAvailable && BVApp.Platform.isSailfish
        anchors.fill: images
        cached: true
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

}

