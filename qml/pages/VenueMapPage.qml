import QtQuick 2.2
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import BerlinVegan.components.platform 1.0 as BVApp

BVApp.Page {

    id: page

    property var venueCoordinate
    property var positionSource
    property alias name : page.title
    property alias map : map

    PageHeader {
        id: header
        y: 0
        title: name
        width: page.width
        z: 5
    }

    Rectangle {
        id: rectangle
        anchors.fill: header
        color: BVApp.Theme.highlightDimmerColor
        opacity: 0.6
        z: 4
    }

    property var venueMarker: MapQuickItem {
        id: venueMarker

        coordinate: venueCoordinate

        anchorPoint.x: venueMarkerImage.width / 2
        anchorPoint.y: venueMarkerImage.height

        sourceItem: BVApp.IconButton {
            id: venueMarkerImage
            type: "location"

            scale: 1.6
            // used only on v-play
            color: "red"

            onClicked: {
                var query = venueCoordinate.latitude + "," + venueCoordinate.longitude
                if (BVApp.Platform.isIos || BVApp.Platform.isMacOS) {
                    Qt.openUrlExternally("https://maps.apple.com/?q=" + query)
                } else {
                    Qt.openUrlExternally("geo:" + query)
                }
            }
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
        }
    }

    FastBlur {
        anchors.fill: header
        source: ShaderEffectSource {
            sourceItem: map
            sourceRect: Qt.rect(0, 0, header.width, header.height)
        }

        radius: 40
        transparentBorder: true
        z: 3
    }

    BVApp.Map {
        id: map
        anchors.fill: parent
        // v-play: it is as easy as that: the copyright notice is usually displayed in the bottom left corner.
        copyrightsVisible: false

        plugin : Plugin {
            name: "osm"
            parameters: [ PluginParameter {
                    name: "osm.mapping.highdpi_tiles"
                    value: "true"
                }]
        }

        gesture {
            enabled: true
        }

        Component.onCompleted: {
            addMapItem(venueMarker)
            addMapItem(currentPosition)
            center = venueCoordinate
            fitViewportToMapItems()
        }

        zoomLevel: maximumZoomLevel - 1
    }
}
