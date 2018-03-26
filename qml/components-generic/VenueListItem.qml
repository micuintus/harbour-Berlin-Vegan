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
import QtQuick.Layouts 1.3

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

    OpeningHoursModel {
        id: openingHoursModel
        restaurant: currRestaurant
    }

    height: column.height

    Column {
        id: column
        width: parent.width

        RowLayout {
            width: parent.width

            Label {
                id: namelabel
                text: model.name
                color: delegate.highlighted ? BVApp.Theme.highlightColor :
                                              BVApp.Platform.isSailfish ? BVApp.Theme.primaryColor : BVApp.Theme.secondaryColor
                Layout.fillWidth: true
                Layout.maximumWidth: namelabel.contentWidth + 1

                Layout.topMargin: BVApp.Theme.paddingMedium
                Layout.leftMargin: BVApp.Theme.horizontalPageMargin

                font.pixelSize: BVApp.Platform.isSailfish ? BVApp.Theme.fontSizeMedium : BVApp.Theme.fontSizeLarge
                truncationMode: TruncationMode.Fade
            }

            BVApp.VeganMarker {
                id: veganMark

                markerSize: namelabel.font.pixelSize * 0.92
                color: BVApp.Theme.colorFor(model.vegan)

                visible: model.vegan >= VenueModel.Vegetarian
            }

            Item {
                id: dummyFiller1
                Layout.fillWidth: true
                Layout.preferredWidth: 0
            }

            Text {
                id: closing
                         //% "closed\nnow"  */
                text: qsTrId("id-venue-closed")
                color: BVApp.Theme.disabledColor

                Layout.maximumWidth: !isOpen ? contentWidth : 0

                Layout.topMargin: BVApp.Theme.paddingMedium
                Layout.rightMargin: isOpen ? 0 : BVApp.Theme.horizontalPageMargin

                opacity: isOpen ? 0 : 1

                font.pixelSize: BVApp.Theme.smallLinkFontSize
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            width: parent.width

            Label {
                id: streetLabel
                text: model.street

                Layout.fillWidth: true
                Layout.maximumWidth: streetLabel.contentWidth + 1

                Layout.topMargin: BVApp.Theme.paddingSmall

                Layout.bottomMargin: BVApp.Theme.paddingMedium
                Layout.leftMargin: BVApp.Theme.horizontalPageMargin

                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                color: BVApp.Theme.secondaryColor

                truncationMode: TruncationMode.Fade
            }

            Item {
                id: dummyFiller2
                Layout.fillWidth: true
                Layout.preferredWidth: 0
            }

            Label {
                id: distance

                color: isOpen ? BVApp.Theme.highlightColor : BVApp.Theme.disabledColor
                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight

                Layout.rightMargin: BVApp.Theme.horizontalPageMargin
            }
        }
    }
}
