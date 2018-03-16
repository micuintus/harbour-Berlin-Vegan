import QtQuick 2.2
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.2
import BerlinVegan.components.platform 1.0 as BVApp
import harbour.berlin.vegan 1.0

Rectangle {

    id: page

    property var venueCoordinate
    property var positionSource
    property var vegan

    property var venueMarker: MapQuickItem {
        id: venueMarker

        coordinate: venueCoordinate

        anchorPoint.x: venueMarkerImage.width / 2
        anchorPoint.y: venueMarkerImage.height

        sourceItem: BVApp.IconButton {
            id: venueMarkerImage
            type: "location"

            scale: 1.6
            color: BVApp.Theme.colorFor(vegan)
            verticalAlignment: Text.AlignBottom
        }
    }

    property var currentPosition: MapQuickItem {
        id: currentPosition

        coordinate: positionSource.position.coordinate

        anchorPoint.x: currentPosImage.width / 2
        anchorPoint.y: currentPosImage.height / 2

        sourceItem: BVApp.IconButton {
            id: currentPosImage
            type: "cover-location"
            color: BVApp.Theme.ownLocationColor
        }
    }

    BVApp.Map {
        id: map
        anchors.fill: parent
        // v-play: it is as easy as that: the copyright notice is usually displayed in the bottom left corner.
        copyrightsVisible: false

        // user shall not move the map, but click to open the coordinates in the dedicated map app.
        gesture {
            enabled: false
        }

        Component.onCompleted: {
            addMapItem(venueMarker)
            addMapItem(currentPosition)
            center = venueCoordinate
            fitViewportToMapItems()
            // HACK: after fitViewportToMapItems() the icons may not be visible
            zoomLevel = zoomLevel - 1
        }

        zoomLevel: maximumZoomLevel - 1
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            var query = venueCoordinate.latitude + "," + venueCoordinate.longitude
            if (BVApp.Platform.isIos || BVApp.Platform.isMacOS) {
                Qt.openUrlExternally("https://maps.apple.com/?q=" + query)
            } else {
                SailfishAndroidBridge.startURIIntent("android.intent.action.VIEW", "geo:" + query);
            }
        }
    }
}
