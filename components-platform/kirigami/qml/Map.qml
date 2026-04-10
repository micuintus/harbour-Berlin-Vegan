import QtQuick
import QtLocation
import QtPositioning

Map {
    id: map

    property bool gestureEnabled: true
    property bool userPositionAvailable: false
    property var userPosition: QtPositioning.coordinate()
    property bool gestureActive: pinchHandler.active || dragHandler.active
    property bool showUserPosition: true

    plugin: Plugin {
        name: "osm"
        PluginParameter { name: "osm.mapping.providersrepository.address"; value: "https://tile.openstreetmap.org/" }
    }

    PinchHandler { id: pinchHandler; target: null }
    DragHandler { id: dragHandler; target: null }

    center: QtPositioning.coordinate(52.5200, 13.4050)
    zoomLevel: 12
}
