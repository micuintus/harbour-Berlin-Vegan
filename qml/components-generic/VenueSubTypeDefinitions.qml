pragma Singleton

import QtQuick 2.5
import harbour.berlin.vegan 1.0

QtObject {
    property list<VenueSubTypeDefinition> foodVenueSubTypes:
    [
        VenueSubTypeDefinition {
                     //% "Restaurant"
            text: qsTrId("id-venue-subtype-restaurant")
            flag: VenueSortFilterProxyModel.RestaurantFlag
        },
        VenueSubTypeDefinition {
                     //% "Snack bar"
            text: qsTrId("id-venue-subtype-fastfood")
            flag: VenueSortFilterProxyModel.FastFoodFlag
        },
        VenueSubTypeDefinition {
                     //% "Café"
            text: qsTrId("id-venue-subtype-cafe")
            flag: VenueSortFilterProxyModel.CafeFlag
        },
        VenueSubTypeDefinition {
                     //% "Ice cream parlor"
            text: qsTrId("id-venue-subtype-icecream")
            flag: VenueSortFilterProxyModel.IceCreamFlag
        },
        VenueSubTypeDefinition {
                     //% "Bar"
            text: qsTrId("id-venue-subtype-bar")
            flag: VenueSortFilterProxyModel.BarFlag
        }
    ]
}
