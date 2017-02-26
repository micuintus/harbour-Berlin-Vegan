import QtQuick 2.2
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import BerlinVegan.components 1.0 as BVApp

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

            onClicked: Qt.openUrlExternally("geo:"
                                            + venueCoordinate.latitude + ","
                                            + venueCoordinate.longitude)
        }
    }

    property var currentPosition: MapQuickItem {
        id: currentPosition

        coordinate: positionSource.position.coordinate

        anchorPoint.x: currentPosImage.width / 2
        anchorPoint.y: currentPosImage.height / 2

        sourceItem: Image {
            id: currentPosImage
            source: "image://theme/icon-cover-location?" + BVApp.Theme.highlightBackgroundColor
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

        plugin : Plugin {
            name: "osm"
        }

        gesture {
            enabled: true
        }

        Component.onCompleted: {
            addMapItem(venueMarker)
            addMapItem(currentPosition)
            center = venueCoordinate
        }

        zoomLevel: maximumZoomLevel - 1
    }
}
