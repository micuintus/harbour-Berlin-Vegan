import QtQuick 2.2

import harbour.berlin.vegan 1.0
import BerlinVegan.components.generic 1.0 as BVApp
import BerlinVegan.components.platform 1.0 as BVApp


Flow {
    id: flow
    property var restaurant
    spacing: BVApp.Theme.paddingMedium
    layoutDirection: Qt.RightToLeft

    BVApp.VenueSubTypeTag {
        color: BVApp.Theme.venueSubTypeTagColor(VenueSortFilterProxyModel.RestaurantFlag)
                 //% "Restaurant"
        text: qsTrId("id-venue-subtype-restaurant")
        visible: restaurant.venueSubType & VenueModel.RestaurantFlag
    }

    BVApp.VenueSubTypeTag {
        color: BVApp.Theme.venueSubTypeTagColor(VenueSortFilterProxyModel.FastFoodFlag)
                 //% "Snack bar"
        text: qsTrId("id-venue-subtype-fastfood")
        visible: restaurant.venueSubType & VenueModel.FastFoodFlag
    }

    BVApp.VenueSubTypeTag {
        color: BVApp.Theme.venueSubTypeTagColor(VenueSortFilterProxyModel.CafeFlag)
                 //% "Café"
        text: qsTrId("id-venue-subtype-cafe")
        visible: restaurant.venueSubType & VenueModel.CafeFlag
    }

    BVApp.VenueSubTypeTag {
        color: BVApp.Theme.venueSubTypeTagColor(VenueSortFilterProxyModel.IceCreamFlag)
                 //% "Ice cream parlor"
        text: qsTrId("id-venue-subtype-icecream")
        visible: restaurant.venueSubType & VenueModel.IceCreamFlag
    }

    BVApp.VenueSubTypeTag {
        color: BVApp.Theme.venueSubTypeTagColor(VenueSortFilterProxyModel.BarFlag)
                 //% "Bar"
        text: qsTrId("id-venue-subtype-bar")
        visible: restaurant.venueSubType & VenueModel.BarFlag
    }

}
