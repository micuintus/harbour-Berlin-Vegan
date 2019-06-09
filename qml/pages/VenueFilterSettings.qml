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
                //% "Venue type"
                text: qsTrId("id-venue-category")
                icon: BVApp.Theme.iconFor("list")
            }

            BVApp.RadioButton {
                id: foodButton
                      //% "Food"
                text: qsTrId("id-food")

                onClicked: {
                    // for SFOS: we need to implement "mutual exclusive", since we currently only have a TextSwitch
                    if (checked) {
                        shoppingButton.checked = false;
                        jsonModelCollection.filterVenueType = VenueModel.FoodFlag;
                    }
                    else {
                        foodButton.checked = true;
                    }
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueType & VenueModel.FoodFlag;
            }

            BVApp.RadioButton {
                id: shoppingButton
                      //% "Shopping"
                text: qsTrId("id-shopping")

                onClicked: {
                    // for SFOS: we need to implement "mutual exclusive", since we currently only have a TextSwitch
                    if (checked) {
                        foodButton.checked = false;
                        jsonModelCollection.filterVenueType = VenueModel.ShoppingFlag;
                    }
                    else {
                        shoppingButton.checked = true;
                    }
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueType & VenueModel.ShoppingFlag;
            }

            Column {

                width: parent.width

                BVApp.SectionHeader {
                    //%          "Opening hours"
                    text: qsTrId("id-opening-hours")
                    icon: BVApp.Theme.iconFor("schedule")
                }

                TextSwitch {
                    //% "Open now"
                    text: qsTrId("id-filter-venue-open-now")
                    onCheckedChanged: {
                        jsonModelCollection.filterOpenNow = checked;
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterOpenNow;

                }
            }

            Column {

                visible: jsonModelCollection.filterVenueType & VenueModel.FoodFlag
                width: parent.width

                BVApp.SectionHeader {
                    //% "Venue sub type"
                    text: qsTrId("id-filter-venue-sub-type")
                    icon: BVApp.Theme.iconFor("coffee")
                }

                Repeater {
                    model: BVApp.VenueSubTypeDefinitions.foodVenueSubTypes
                    TextSwitch {
                        text: model.text
                        onCheckedChanged: {
                            jsonModelCollection.setVenueSubTypeFilterFlag(model.flag, checked);
                        }

                        Component.onCompleted: checked = jsonModelCollection.filterVenueSubType & model.flag;
                    }
                }
            }

            BVApp.SectionHeader {
                //% "Veg*an category"
                text: qsTrId("id-filter-vegan-category")
                icon: BVApp.Theme.iconFor("vegan")
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

            Column {

                visible: jsonModelCollection.filterVenueType & VenueModel.FoodFlag
                width: parent.width

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

                TextSwitch {
                    text: qsTrId("id-breakfast")
                    onCheckedChanged: {
                        jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Breakfast, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Breakfast;
                }

                TextSwitch {
                    text: qsTrId("id-brunch")
                    onCheckedChanged: {
                        jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Brunch, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Brunch;
                }
            }
        }
    }
}

