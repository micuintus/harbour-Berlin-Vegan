import QtQuick 2.2

import harbour.berlin.vegan 1.0
import BerlinVegan.components.generic 1.0 as BVApp
import BerlinVegan.components.platform 1.0 as BVApp


Flow {
    id: flow
    property var restaurant
    spacing: BVApp.Theme.paddingMedium
    layoutDirection: Qt.RightToLeft

    Repeater {
        model: BVApp.VenueSubTypeDefinitions.foodVenueSubTypes

        BVApp.VenueSubTypeTag {
            color: BVApp.Theme.venueSubTypeTagColor(model.flag)
            text: model.text
            visible: restaurant.venueSubType & model.flag
        }
    }
}
