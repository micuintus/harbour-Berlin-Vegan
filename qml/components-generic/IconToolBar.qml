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
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Column {
    property var restaurant

    id: column

    Separator {
        width: column.width
        horizontalAlignment: Qt.AlignCenter
        color: BVApp.Theme.secondaryHighlightColor
        height: BVApp.Theme.dividerHeight
    }

    RowLayout {
        id: row
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Layout.maximumWidth: column.width/2

        width: column.width

        BVApp.IconButton {
            type: "answer"
            scale: BVApp.Theme.iconSizeMedium / BVApp.Theme.iconSizeLarge

            onClicked: Qt.openUrlExternally("tel:/" + restaurant.telephone)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            enabled: typeof restaurant["telephone"] !== "undefined"
        }

        BVApp.IconButton {
            function contains() {
                var rs
                db.transaction(function(tx) {
                    rs = tx.executeSql("SELECT * FROM BerlinVegan WHERE favorite_id == ?", [ restaurant.id ]);
                })
                if (rs.rows.length) {
                    return true;
                } else {
                    return false;
                }
            }
            type: contains() ? "favorite" : "favorite-o"
            onClicked: {
                switch (type) {
                case "favorite-o":
                    type = "favorite"
                    db.transaction(function(tx) {
                        tx.executeSql("INSERT INTO BerlinVegan VALUES(?)", [ restaurant.id ]);
                    })
                    // if favorite_id is actually a shopping location, nothing happens
                    jsonFavoritesModel.add(jsonVenueModel.get(restaurant.id))
                    // if favorite_id is actually a venue, nothing happens
                    jsonFavoritesModel.add(jsonShoppingModel.get(restaurant.id))
                    break
                case "favorite":
                    type = "favorite-o"
                    db.transaction(function(tx) {
                        tx.executeSql("DELETE FROM BerlinVegan WHERE favorite_id == ?", [ restaurant.id ]);
                    })
                    if (typeof jsonVenueModel.get(restaurant.id) !== "undefined") {
                        jsonFavoritesModel.remove(jsonVenueModel.get(restaurant.id))
                    } else if (typeof jsonShoppingModel.get(restaurant.id) !== "undefined") {
                        jsonFavoritesModel.remove(jsonShoppingModel.get(restaurant.id))
                    }
                    break
                }
            }
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }


        BVApp.IconButton {
            type: "home"

            onClicked: Qt.openUrlExternally(restaurant.website.slice(0,4) === "http"
                                            ?             restaurant.website
                                            : "http://" + restaurant.website)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            enabled: typeof restaurant["website"] !== "undefined"
        }

    }

    Separator {
        width: column.width
        horizontalAlignment: Qt.AlignCenter
        color: BVApp.Theme.secondaryHighlightColor
        height: BVApp.Theme.dividerHeight
    }
}

