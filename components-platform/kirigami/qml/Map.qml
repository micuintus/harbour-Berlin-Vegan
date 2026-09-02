import QtQuick
import QtLocation
import QtPositioning

// Vector tiles through the Qt Location "maplibre" plugin when QMapLibre is
// available, raster osm otherwise. Same QML either way; only which geoservices
// plugin the loader finds differs.
Map {
    id: map

    property bool gestureEnabled: true
    property bool userPositionAvailable: false
    property var userPosition: QtPositioning.coordinate()
    readonly property bool gestureActive: pinchHandler.active || dragHandler.active
                                          || zoomAnimation.running
    property bool showUserPosition: true

    // Asked of the plugin loader rather than the build system, so it reports
    // what Qt actually resolved at runtime.
    readonly property bool vectorTiles:
        pluginProbe.availableServiceProviders.indexOf("maplibre") >= 0

    Plugin { id: pluginProbe }

    plugin: Plugin {
        name: map.vectorTiles ? "maplibre" : "osm"
        parameters: map.vectorTiles
            ? [ mapLibreStyle ]
            : [ osmProviders ]
    }

    // Qt Location's copyright overlay does not work with the maplibre plugin,
    // so the attribution is drawn by the page instead.
    copyrightsVisible: !map.vectorTiles

    center: QtPositioning.coordinate(52.5200, 13.4050)
    zoomLevel: 12

    PluginParameter {
        id: mapLibreStyle
        name: "maplibre.map.styles"
        value: "https://tiles.openfreemap.org/styles/liberty"
    }

    PluginParameter {
        id: osmProviders
        name: "osm.mapping.providersrepository.address"
        value: "https://tile.openstreetmap.org/"
    }

    NumberAnimation {
        id: zoomAnimation
        target: map
        property: "zoomLevel"
        duration: 350
        easing.type: Easing.OutCubic
    }

    // Rotation stays locked: a dead zone rather than an equality test, so pinch
    // jitter of a thousandth of a degree does not fight the correction.
    onBearingChanged: if (Math.abs(bearing) > 1.0) bearing = 0.0

    PinchHandler {
        id: pinchHandler
        target: null
        enabled: map.gestureEnabled
        onActiveChanged: if (active) zoomAnimation.stop()
        onScaleChanged: (delta) => {
            map.zoomLevel += Math.log2(delta)
        }
    }

    DragHandler {
        id: dragHandler
        target: null
        enabled: map.gestureEnabled
        onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
    }

    WheelHandler {
        enabled: map.gestureEnabled
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            map.zoomLevel += event.angleDelta.y / 480
        }
    }

    TapHandler {
        enabled: map.gestureEnabled
        onDoubleTapped: (eventPoint) => {
            const target = map.toCoordinate(eventPoint.position)
            zoomAnimation.stop()
            zoomAnimation.from = map.zoomLevel
            zoomAnimation.to = Math.min(map.zoomLevel + 1, map.maximumZoomLevel)
            zoomAnimation.start()
            map.alignCoordinateToPoint(target, eventPoint.position)
        }
    }
}
