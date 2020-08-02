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

            BVApp.TextSwitch  {
                id: foodButton
                         //% "Eating out"
                text: qsTrId("id-gastro")

                onUserToggled: {
                    if (checked) {
                        jsonModelCollection.filterVenueType = VenueModel.ShopFlag;
                    }
                    else {
                        jsonModelCollection.filterVenueType = VenueModel.GastroFlag;
                    }
                }

                automaticCheck: false
                checked: jsonModelCollection.filterVenueType === VenueModel.GastroFlag
            }

            BVApp.TextSwitch {
                id: shoppingButton
                         //% "Shops"
                text: qsTrId("id-shops")

                onUserToggled: {
                    if (checked) {
                        jsonModelCollection.filterVenueType = VenueModel.GastroFlag;
                    }
                    else {
                        jsonModelCollection.filterVenueType = VenueModel.ShopFlag;
                    }
                }

                automaticCheck: false
                checked: jsonModelCollection.filterVenueType === VenueModel.ShopFlag
            }

            Column {

                width: parent.width

                BVApp.SectionHeader {
                    //%          "Opening hours"
                    text: qsTrId("id-opening-hours")
                    icon: BVApp.Theme.iconFor("schedule")
                }

                BVApp.TextSwitch {
                    //% "Open now"
                    text: qsTrId("id-filter-venue-open-now")
                    onUserToggled: {
                        jsonModelCollection.filterOpenNow = !checked;
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterOpenNow
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
                    BVApp.TextSwitch {
                        text: model.text
                        onUserToggled: {
                            jsonModelCollection.setVenueSubTypeFilterFlag(model.flag, !checked);
                        }

                        automaticCheck: false
                        checked: jsonModelCollection.filterVenueSubType & model.flag;
                    }
                }
            }

            BVApp.SectionHeader {
                //% "Veg*an category"
                text: qsTrId("id-filter-vegan-category")
                icon: BVApp.Theme.iconFor("vegan")
            }

            BVApp.TextSwitch {
                text: qsTrId("id-vegan")
                onUserToggled: {
                    jsonModelCollection.setVegCategoryFilterFlag(VenueSortFilterProxyModel.VeganFlag, !checked);
                }

                automaticCheck: false
                checked: jsonModelCollection.filterVegCategory & VenueSortFilterProxyModel.VeganFlag
            }

            BVApp.TextSwitch {
                text: qsTrId("id-vegetarian")
                onUserToggled: {
                    jsonModelCollection.setVegCategoryFilterFlag(VenueSortFilterProxyModel.VegetarianFlag, !checked);
                }

                automaticCheck: false
                checked: jsonModelCollection.filterVegCategory & VenueSortFilterProxyModel.VegetarianFlag
            }

            BVApp.TextSwitch {
                text: qsTrId("id-omnivorous")
                onUserToggled: {
                    jsonModelCollection.setVegCategoryFilterFlag(VenueSortFilterProxyModel.OmnivorousFlag, !checked);
                }

                automaticCheck: false
                checked: jsonModelCollection.filterVegCategory & VenueSortFilterProxyModel.OmnivorousFlag
            }

            Column {
                width: parent.width

                BVApp.SectionHeader {
                    text: qsTrId("id-venue-features")
                    icon: BVApp.Theme.iconFor("more_vert")
                }

                BVApp.TextSwitch {
                    text: qsTrId("id-organic")
                    onUserToggled: {
                        jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Organic, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Organic
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-gluten-free")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.GlutenFree, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.GlutenFree
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-breakfast")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Breakfast, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Breakfast
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-brunch")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Brunch, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Brunch
                }

                BVApp.TextSwitch {
                    text: qsTrId("id-wheelchair")
                    onUserToggled: {
                        jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.HandicappedAccessible, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.HandicappedAccessible
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-wheelchair-wc")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.HandicappedAccessibleWc, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.HandicappedAccessibleWc
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-high-chair")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.ChildChair, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.ChildChair
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-dogs-allowed")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Dog, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Dog
                }

                BVApp.TextSwitch {
                    text: qsTrId("id-delivery")
                    onUserToggled: {
                        jsonModelCollection.setVenuePropertyFilterFlag(VenueSortFilterProxyModel.Delivery, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterVenueProperty & VenueSortFilterProxyModel.Delivery
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-catering")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Catering, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Catering
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                    text: qsTrId("id-wifi")
                    onUserToggled: {
                        jsonModelCollection.setGastroPropertyFilterFlag(VenueSortFilterProxyModel.Wlan, !checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterGastroProperty & VenueSortFilterProxyModel.Wlan
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                             //% "With review (German)"
                    text: qsTrId("id-filter-with-review")
                    onUserToggled: {
                        jsonModelCollection.setFilterWithReview(!checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterWithReview
                }
            }

            Column {

                width: parent.width

                BVApp.SectionHeader {
                    //%          "New in database"
                    text: qsTrId("id-new-in-database")
                    icon: BVApp.Theme.iconFor("date_range")
                }

                BVApp.TextSwitch {
                    visible: showGastroVenues
                             //% "New"
                    text: qsTrId("id-new")
                    onUserToggled: {
                        jsonModelCollection.setFilterNew(!checked);
                    }

                    automaticCheck: false
                    checked: jsonModelCollection.filterNew
                }

                BVApp.ValueSelector
                {
                    visible: showGastroVenues
                    id: vs
                              //% "A venue is new for:"
                    label: qsTrId("id-meaning-new")
                                          //% "month"
                    labelUnitSingular: qsTrId("id-month")
                                        //% "months"
                    labelUnitPlural: qsTrId("id-months")

                    from: 1
                    to: 50
                    stepSize: 1

                    onValueModified: {
                        jsonModelCollection.setMonthNew(value);
                    }

                    value: jsonModelCollection.monthNew
                }
            }

            Item {
                width: parent.width
                height: BVApp.Theme.paddingLarge * 1.3
            }
        }
    }
}

