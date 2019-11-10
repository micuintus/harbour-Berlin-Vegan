import QtQuick 2.5
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.2
import BerlinVegan.components.platform 1.0 as BVApp

Rectangle {

    id: page

    property var venueCoordinate
    property var positionSource
    property var vegan

    property var venueMarker: MapQuickItem {
        id: venueMarker

        coordinate: venueCoordinate

        scale: 1 / map.scale

        anchorPoint.x: venueMarkerImage.width / 2
        anchorPoint.y: venueMarkerImage.height

        sourceItem: BVApp.IconButton {
            id: venueMarkerImage
            type: "location"

            scale: 1.6
            color: BVApp.Theme.vegTypeColor(vegan)
            verticalAlignment: Text.AlignBottom
        }
    }

    property var currentPosition: MapQuickItem {
        id: currentPosition

        scale: 1 / map.scale

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
            if (BVApp.Platform.isIos) {
                // displays a modal alert sheet with the specific options. It uses an AlertDialog on Android and a UIActionSheet on iOS.
                nativeUtils.displayAlertSheet("", ["Apple Maps", "Google Maps"], true);
            } else if (BVApp.Platform.isMacOS) {
                Qt.openUrlExternally("https://maps.apple.com/?q=" + query)
            } else if (BVApp.Platform.isAndroid) {
                Qt.openUrlExternally("https://maps.google.com/?q=" + query);
            } else {
                Qt.openUrlExternally("geo:" + query)
            }
        }
    }

    // the result of the input dialog is received with a connection to the signal textInputFinished
    Connections {
        // supress warning "ReferenceError: nativeUtils is not defined" on SailfishOS by setting target to "null"
        target: BVApp.Platform.isIos ? nativeUtils : null
        onAlertSheetFinished: {
            // cancel was clicked
            if (index === -1) {
                return;
            }

            var url = "apple";
            if (index === 1) {
                url = "google";
            }

            var query = venueCoordinate.latitude + "," + venueCoordinate.longitude
            nativeUtils.openUrl("https://maps." + url + ".com/?q=" + query);
        }
    }
}
