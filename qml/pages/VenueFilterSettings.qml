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
import harbour.berlin.vegan 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

BVApp.Page {
    id: page

    property var jsonModelCollection

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width


            PageHeader {
                id: pageHeader
                             //% "Filter settings"
                title: qsTrId("id-filter-page-title")

            }

            BVApp.SectionHeader {
                //% "Veg*an category"
                text: qsTrId("id-filter-vegan-category")
                icon: BVApp.Theme.iconFor("leaf")
            }

            TextSwitch {
                text: qsTrId("id-vegan")
                onCheckedChanged: {
                    jsonModelCollection.setVegCategoryFilterFlag(VenueSortFilterProxyModel.VeganFlag, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVegCategory & VenueSortFilterProxyModel.VeganFlag;

            }

            TextSwitch {
                text: qsTrId("id-vegetarian")
                onCheckedChanged: {
                    jsonModelCollection.setVegCategoryFilterFlag(VenueSortFilterProxyModel.VegetarianFlag, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVegCategory & VenueSortFilterProxyModel.VegetarianFlag;
            }

            TextSwitch {
                text: qsTrId("id-omnivore")
                onCheckedChanged: {
                    jsonModelCollection.setVegCategoryFilterFlag(VenueSortFilterProxyModel.OmnivoreFlag, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVegCategory & VenueSortFilterProxyModel.OmnivoreFlag;

            }

            BVApp.SectionHeader {
                text: qsTrId("id-venue-features")
                icon: BVApp.Theme.iconFor("more_vert")
            }

            TextSwitch {
                text: qsTrId("id-organic")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Organic, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Organic;

            }

            TextSwitch {
                text: qsTrId("id-gluten-free")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.GlutenFree, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.GlutenFree;
            }

            TextSwitch {
                text: qsTrId("id-wheelchair")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.HandicappedAccessible, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.HandicappedAccessible;
            }

            TextSwitch {
                text: qsTrId("id-wheelchair-wc")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.HandicappedAccessibleWc , checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.HandicappedAccessibleWc;
            }

            TextSwitch {
                text: qsTrId("id-high-chair")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.ChildChair, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.ChildChair;
            }

            TextSwitch {
                text: qsTrId("id-dogs-allowed")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Dog, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Dog;
            }

            TextSwitch {
                text: qsTrId("id-wifi")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Wlan, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Wlan;
            }

            TextSwitch {
                text: qsTrId("id-catering")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Catering, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Catering
            }

            TextSwitch {
                text: qsTrId("id-delivery")
                onCheckedChanged: {
                    jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Delivery, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Delivery;
            }
        }
    }
}

