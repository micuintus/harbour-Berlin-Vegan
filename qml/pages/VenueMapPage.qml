import QtQuick 2.2
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.2

Page {

    id: page

    property var venueCoordinate
    property var positionSource
    property string name
    property alias map : map

    // TODO: Directly assigning a coordinate property to Map.center seems to be broken
    // with the current Qt version (5.2)
    function setMapCenter(mapCenter)
    {
        map.center = mapCenter
        map.update()

    }

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
        color: Theme.highlightDimmerColor
        opacity: 0.6
        z: 4
    }

    property var venueMarker: MapQuickItem {
        id: venueMarker

        coordinate: venueCoordinate

        anchorPoint.x: venueMarkerImage.width / 2
        anchorPoint.y: venueMarkerImage.height

        sourceItem: IconButton {
            id: venueMarkerImage
            icon.source: "image://theme/icon-m-location?" + Theme.highlightBackgroundColor

            icon.scale: 1.6

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
            source: "image://theme/icon-cover-location?" + Theme.highlightBackgroundColor
        }
    }

    Map {
        id: map
        anchors.fill: parent

        plugin : Plugin {
            name: "osm"
        }

        gesture {
            enabled: true
        }


        zoomLevel: maximumZoomLevel - 1
    }
}
