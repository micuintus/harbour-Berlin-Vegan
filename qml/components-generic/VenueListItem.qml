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

import QtQuick 2.2
import Sailfish.Silica 1.0

import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

import harbour.berlin.vegan 1.0

ListItem {
    id: delegate
    property var currRestaurant
    // may not be a function, because otherwise re-evaluating of the property binding won't work,
    // because the NOTIFY-signal is missing
    //
    // See: http://blog.mardy.it/2016/11/qml-trick-force-re-evaluation-of.html
    property bool isOpen: openingHoursModel.isOpen
    property alias distanceText: distance.text

    contentHeight: namelabel.anchors.topMargin +
                            // first column:  namelabel and streetLabel
                   Math.max(namelabel.height + streetLabel.anchors.topMargin + streetLabel.height,
                            // second coulmn: closing info and distance
                            closing.height + distance.anchors.topMargin + distance.height)
                 + namelabel.anchors.topMargin // <<- We'd like to have the same padding on the bottom as on the top

    Label {
        id: namelabel
        text: model.name
        color: delegate.highlighted ? BVApp.Theme.highlightColor :
                                      BVApp.Platform.isSailfish ? BVApp.Theme.primaryColor : BVApp.Theme.secondaryColor

        width: Math.min(namelabel.contentWidth,
                        // space that is left after substracting all the other elements from the available width
                        delegate.width
                        - (namelabel.anchors.leftMargin
                           + (veganMark.visible ? veganMark.anchors.leftMargin + veganMark.width  : 0)
                           + (veganMark.visible && closing.visible ? veganMark.anchors.rightMargin : 0)
                           + (closing.visible ? closing.width + closing.anchors.leftMargin : 0)
                           + distance.anchors.rightMargin))

        font.pixelSize: BVApp.Platform.isSailfish ? BVApp.Theme.fontSizeMedium : BVApp.Theme.fontSizeLarge
        truncationMode: TruncationMode.Fade
        anchors {
            top: parent.top
            left: parent.left

            topMargin: BVApp.Theme.paddingMedium
            leftMargin: BVApp.Theme.horizontalPageMargin
        }
    }

    BVApp.VeganMarker {
        id: veganMark

        markerSize: namelabel.font.pixelSize * 0.92
        color: BVApp.Theme.colorFor(model.vegan)

        visible: model.vegan >= VenueModel.Vegetarian

        anchors {
            left: namelabel.right
            top: namelabel.top

            leftMargin: height * 0.16
            rightMargin: BVApp.Theme.horizontalPageMargin
        }
    }

    OpeningHoursModel {
        id: openingHoursModel
        restaurant: currRestaurant
    }

    Label {
        id: closing

        visible: !isOpen
                 //% "closed now"
        text: qsTrId("id-venue-closed")
        color: BVApp.Theme.disabledColor

        width: !isOpen ? contentWidth : 0

        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
        horizontalAlignment: Text.AlignRight
        anchors {
            top: namelabel.top
            right: parent.right

            leftMargin: BVApp.Theme.horizontalPageMargin
            rightMargin: BVApp.Theme.horizontalPageMargin
        }
    }

    Label {
        id: distance

        color: isOpen ? BVApp.Theme.highlightColor : BVApp.Theme.disabledColor
        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
        horizontalAlignment: Text.AlignRight
        anchors {
            right: parent.right

            top: closing.bottom

            topMargin: BVApp.Theme.paddingMedium
            rightMargin: BVApp.Theme.horizontalPageMargin

            bottomMargin: namelabel.anchors.topMargin
        }
    }

    Label {
        id: streetLabel
        text: model.street

        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
        color: BVApp.Theme.secondaryColor

        truncationMode: TruncationMode.Fade
        anchors {
            left: parent.left
            right: distance.left

            baseline: distance.baseline

            top: namelabel.top
            bottom: parent.bottom

            leftMargin: BVApp.Theme.horizontalPageMargin
            rightMargin: BVApp.Theme.horizontalPageMargin

            topMargin: BVApp.Theme.paddingMedium
            bottomMargin: namelabel.anchors.topMargin
        }
    }
}
