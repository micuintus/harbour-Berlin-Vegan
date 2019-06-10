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

    property list<VenueSubTypeDefinition> shopsVenueSubTypes:
    [
        VenueSubTypeDefinition {
                     //% "Food"
            text: qsTrId("id-venue-subtype-foods")
            flag: VenueSortFilterProxyModel.FoodsFlag
        },
        VenueSubTypeDefinition {
                     //% "Fashion"
            text: qsTrId("id-venue-subtype-clothing")
            flag: VenueSortFilterProxyModel.ClothingFlag
        },
        VenueSubTypeDefinition {
                     //% "Toiletries"
            text: qsTrId("id-venue-subtype-toiletries")
            flag: VenueSortFilterProxyModel.ToiletriesFlag
        },
        VenueSubTypeDefinition {
                     //% "Supermarket"
            text: qsTrId("id-venue-subtype-supermarket")
            flag: VenueSortFilterProxyModel.SupermarketFlag
        },
        VenueSubTypeDefinition {
                     //% "Hairdresser's"
            text: qsTrId("id-venue-subtype-hairdressers")
            flag: VenueSortFilterProxyModel.HairdressersFlag
        },
        VenueSubTypeDefinition {
                     //% "Sports"
            text: qsTrId("id-venue-subtype-sports")
            flag: VenueSortFilterProxyModel.SportsFlag
        },
        VenueSubTypeDefinition {
                     //% "Tattoo studio"
            text: qsTrId("id-venue-subtype-tattoostudio")
            flag: VenueSortFilterProxyModel.TattoostudioFlag
        },
        VenueSubTypeDefinition {
                     //% "Accommodation"
            text: qsTrId("id-venue-subtype-accommodation")
            flag: VenueSortFilterProxyModel.AccommodationFlag
        }
    ]
}
