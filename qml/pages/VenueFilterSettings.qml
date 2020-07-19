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
import harbour.berlin.vegan 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

BVApp.Page {
    id: page

    property var jsonModelCollection
    property bool showGastroVenues: jsonModelCollection.filterVenueType & VenueModel.GastroFlag

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                id: pageHeader
                             //% "Filter settings"
                title: qsTrId("id-filter-page-title")

            }

            Item {
                width: parent.width
                height: BVApp.Platform.isSailfish ? 0 : 2 * BVApp.Theme.paddingLarge
            }

            Label {
                width: parent.width
                                                           //% "venues selected"
                text: jsonModelCollection.count + " " + qsTrId("id-selected")
                horizontalAlignment: Text.AlignHCenter
                color: BVApp.Theme.highlightColor
                font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                font.italic: true
            }

            Item {
                width: parent.width
                height: BVApp.Platform.isSailfish ? BVApp.Theme.paddingLarge : 0
            }

            BVApp.SectionHeader {
                         //% "Venue category"
                text: qsTrId("id-venue-category")
                icon: BVApp.Theme.iconFor("list")
            }

            TextSwitch  {
                id: foodButton
                         //% "Eating out"
                text: qsTrId("id-gastro")

                onCheckedChanged: {
                    // for SFOS: we need to implement "mutual exclusive", since we currently only have a TextSwitch
                    if (checked) {
                        shoppingButton.checked = false;
                        jsonModelCollection.filterVenueType = VenueModel.GastroFlag;
                    }
                    else {
                        shoppingButton.checked = true;
                    }
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueType & VenueModel.GastroFlag;
            }

            TextSwitch {
                id: shoppingButton
                         //% "Shops"
                text: qsTrId("id-shops")

                onCheckedChanged: {
                    // for SFOS: we need to implement "mutual exclusive", since we currently only have a TextSwitch
                    if (checked) {
                        foodButton.checked = false;
                        jsonModelCollection.filterVenueType = VenueModel.ShopFlag;
                    }
                    else {
                        foodButton.checked = true;
                    }
                }

                Component.onCompleted: checked = jsonModelCollection.filterVenueType & VenueModel.ShopFlag;
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
                width: parent.width

                BVApp.SectionHeader {
                             //% "Sub category"
                    text: qsTrId("id-filter-venue-sub-type")
                    icon: BVApp.Theme.iconFor("coffee")
                }

                Repeater {
                    model: showGastroVenues ?
                               BVApp.VenueSubTypeDefinitions.gastroVenueSubTypes
                             : BVApp.VenueSubTypeDefinitions.shopVenueSubTypes
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
                text: qsTrId("id-omnivorous")
                onCheckedChanged: {
                    jsonModelCollection.setVegCategoryFilterFlag(VenueSortFilterProxyModel.OmnivorousFlag, checked);
                }

                Component.onCompleted: checked = jsonModelCollection.filterVegCategory & VenueSortFilterProxyModel.OmnivorousFlag;
            }

            Column {

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
                    visible: showGastroVenues
                    text: qsTrId("id-gluten-free")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.GlutenFree, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.GlutenFree;
                }

                TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-breakfast")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Breakfast, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Breakfast;
                }

                TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-brunch")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Brunch, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Brunch;
                }

                TextSwitch {
                    text: qsTrId("id-wheelchair")
                    onCheckedChanged: {
                        jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.HandicappedAccessible, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.HandicappedAccessible;
                }

                TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-wheelchair-wc")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.HandicappedAccessibleWc , checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.HandicappedAccessibleWc;
                }

                TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-high-chair")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.ChildChair, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.ChildChair;
                }

                TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-dogs-allowed")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Dog, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Dog;
                }

                TextSwitch {
                    text: qsTrId("id-delivery")
                    onCheckedChanged: {
                        jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Delivery, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Delivery;
                }

                TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-catering")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Catering, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Catering
                }

                TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-wifi")
                    onCheckedChanged: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Wlan, checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Wlan;
                }

                TextSwitch {
                    visible: showGastroVenues
                             //% "With review (German)"
                    text: qsTrId("id-filter-with-review")
                    onCheckedChanged: {
                        jsonModelCollection.setFilterWithReview(checked);
                    }

                    Component.onCompleted: checked = jsonModelCollection.filterWithReview;
                }
            }
        }
    }
}

