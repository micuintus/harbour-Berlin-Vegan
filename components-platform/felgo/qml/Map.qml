// Custom map with gesture handlers copied from Qt's MapView.qml.
// Felgo's felgoApp.initialize() installs touch interception that prevents
// QML PointerHandlers from receiving multi-touch when using stock MapView.
// Using aggressive grabPermissions to steal grabs from any Felgo handler.

import QtQuick
import QtLocation as QL
import QtPositioning as QP
import Qt.labs.animation

Item {
    id: root

    readonly property alias mapTarget: map
    property alias center: map.center
    property alias zoomLevel: map.zoomLevel
    property alias bearing: map.bearing
    property alias tilt: map.tilt
    property alias maximumZoomLevel: map.maximumZoomLevel
    property alias minimumZoomLevel: map.minimumZoomLevel
    property alias copyrightsVisible: map.copyrightsVisible
    property bool gestureEnabled: true

    function addMapItem(item) { map.addMapItem(item) }
    function removeMapItem(item) { map.removeMapItem(item) }
    function fitViewportToMapItems() { map.fitViewportToMapItems() }

    // Reparent declarative Map children (MapItemView, etc.) to the inner Map
    default property alias mapData: map.data

    Component.onCompleted: map.resetPinchMinMax()

    QL.Map {
        id: map
        width: parent.width
        height: parent.height
        copyrightsVisible: false
        property bool pinchAdjustingZoom: false

        plugin: QL.Plugin {
            name: "maplibre"
            parameters: [
                QL.PluginParameter {
                    name: "maplibre.map.styles"
                    value: "https://tiles.openfreemap.org/styles/liberty"
                }
            ]
        }

        BoundaryRule on zoomLevel {
            id: br
            minimum: map.minimumZoomLevel
            maximum: map.maximumZoomLevel
        }

        onZoomLevelChanged: {
            br.returnToBounds()
            if (!pinchAdjustingZoom) resetPinchMinMax()
        }

        function resetPinchMinMax() {
            pinch.persistentScale = 1
            pinch.scaleAxis.minimum = Math.pow(2, root.minimumZoomLevel - map.zoomLevel + 1)
            pinch.scaleAxis.maximum = Math.pow(2, root.maximumZoomLevel - map.zoomLevel - 1)
        }

        PinchHandler {
            id: pinch
            target: null
            property QP.geoCoordinate startCentroid
            // AGGRESSIVE grab — steal from any Felgo handler that grabs first
            grabPermissions: PointerHandler.CanTakeOverFromAnything
            onActiveChanged: if (active) {
                flickAnimation.stop()
                pinch.startCentroid = map.toCoordinate(pinch.centroid.position, false)
            } else {
                flickAnimation.restart(centroid.velocity)
                map.resetPinchMinMax()
            }
            onScaleChanged: (delta) => {
                map.pinchAdjustingZoom = true
                map.zoomLevel += Math.log2(delta)
                map.alignCoordinateToPoint(pinch.startCentroid, pinch.centroid.position)
                map.pinchAdjustingZoom = false
            }
            // onRotationChanged intentionally omitted — rotation disabled
        }

        WheelHandler {
            id: wheel
            acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                             ? PointerDevice.Mouse | PointerDevice.TouchPad
                             : PointerDevice.Mouse
            onWheel: (event) => {
                const loc = map.toCoordinate(wheel.point.position)
                map.zoomLevel += event.angleDelta.y / 120
                map.alignCoordinateToPoint(loc, wheel.point.position)
            }
        }

        DragHandler {
            id: drag
            signal flickStarted
            signal flickEnded
            target: null
            grabPermissions: PointerHandler.CanTakeOverFromAnything
            onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
            onActiveChanged: if (active) {
                flickAnimation.stop()
            } else {
                flickAnimation.restart(centroid.velocity)
            }
        }

        property vector3d animDest
        onAnimDestChanged: if (flickAnimation.running) {
            const delta = Qt.vector2d(animDest.x - flickAnimation.animDestLast.x,
                                      animDest.y - flickAnimation.animDestLast.y)
            map.pan(-delta.x, -delta.y)
            flickAnimation.animDestLast = animDest
        }

        Vector3dAnimation on animDest {
            id: flickAnimation
            property vector3d animDestLast
            from: Qt.vector3d(0, 0, 0)
            duration: 500
            easing.type: Easing.OutQuad
            onStarted: drag.flickStarted()
            onStopped: drag.flickEnded()

            function restart(vel) {
                stop()
                map.animDest = Qt.vector3d(0, 0, 0)
                animDestLast = Qt.vector3d(0, 0, 0)
                to = Qt.vector3d(vel.x / duration * 100, vel.y / duration * 100, 0)
                start()
            }
        }

        // Double-tap-to-zoom (onDoubleTapped doesn't fire because
        // DragHandler grabs on first press; use tapCount instead)
        TapHandler {
            id: tapZoom
            grabPermissions: PointerHandler.CanTakeOverFromAnything
            onTapped: (eventPoint, button) => {
                if (tapCount === 2) {
                    flickAnimation.stop()
                    const loc = map.toCoordinate(tapZoom.point.position)
                    map.zoomLevel = Math.min(map.zoomLevel + 1, root.maximumZoomLevel)
                    map.alignCoordinateToPoint(loc, tapZoom.point.position)
                }
            }
        }
    }
}
