// Felgo AppMap wrapper.
// AppMap (Felgo 4.x) extends Qt Location's Map with built-in gesture
// handling, permission-aware showUserPosition, and Felgo-compatible
// touch interception.  We add only what AppMap does not provide:
//   * rotation lock               (onBearingChanged dead-zone snap)
//   * double-tap zoom             (Timer-based TapHandler)
//   * double-tap-hold-drag zoom   (parklibre pattern, DragHandler + proximity check)
//   * pan fallback after tap      (DragHandler drives pan when grab is stolen)
//   * gesture tap suppression     (gestureActive for marker delegates)
//
// NOTE: pinch-to-zoom inertia was intentionally NOT added here.
// AppMap already owns pinch handling in C++; layering a NumberAnimation
// on top creates competing zoom drivers and causes clunkiness.

import Felgo
import QtQuick
import QtLocation as QL

AppMap {
    id: root

    // -- Compatibility alias (kept so callers can still write map.mapTarget) --
    readonly property alias mapTarget: root
    property bool gestureEnabled: true

    // -- Gesture tap suppression ─────────────────────────────────────────────
    // True while any custom gesture or coast animation is in progress.
    // Marker delegates check this before opening the venue detail page.
    readonly property bool gestureActive: _holdZoomActive || zoomAnimation.running

    // -- Map setup ───────────────────────────────────────────────────────────
    copyrightsVisible: false
    showUserPosition: true      // Felgo handles permission request + blue dot

    plugin: QL.Plugin {
        name: "maplibre"
        parameters: [
            QL.PluginParameter {
                name: "maplibre.map.styles"
                value: "https://tiles.openfreemap.org/styles/liberty"
            }
        ]
    }

    // -- Lock rotation ───────────────────────────────────────────────────────
    // Snap bearing back to 0 only when it drifts beyond a small dead zone.
    // Using a threshold rather than != 0.0 avoids repeated micro-corrections
    // during pinch gestures (AppMap may internally set bearing to ±0.001°),
    // which would otherwise cause subtle per-frame jitter.
    onBearingChanged: if (Math.abs(bearing) > 1.0) bearing = 0.0

    // -- Double-tap-to-zoom + double-tap-hold-drag-to-zoom ───────────────────
    //
    // DOUBLE-TAP (release): Timer-based, immune to Felgo's grab-interception
    //   that resets Qt's internal tapCount between the two taps.
    //
    // DOUBLE-TAP-HOLD-DRAG (parklibre pattern):
    //   After the first tap the doubleTapTimer is running.  If the user presses
    //   again and holds, DragHandler is enabled during the timer window +
    //   while _holdZoomActive.  Vertical movement converts to zoom level.
    //
    //   Drag down = zoom in, drag up = zoom out (Google Maps / parklibre style).
    //   Scaling factor: 100 px ~ 1 zoom level (same as parklibre).
    //
    //   Zoom inertia: on release, continue zooming based on vertical velocity.

    property bool _holdZoomActive: false

    NumberAnimation {
        id: zoomAnimation
        target: root
        property: "zoomLevel"
        duration: 350
        easing.type: Easing.OutCubic
    }

    Timer {
        id: doubleTapTimer
        interval: 300
        property point tappedPos
        onTriggered: {
            root._holdZoomActive = false
        }
    }

    // -- Passive second-press detector ───────────────────────────────────────
    // (Removed: PointHandler approach caused map clunkiness by interfering
    //  with AppMap's internal touch handling even with passive grabs.)

    TapHandler {
        id: tapZoom
        onTapped: (eventPoint, button) => {
            if (doubleTapTimer.running) {
                const dx = eventPoint.position.x - doubleTapTimer.tappedPos.x
                const dy = eventPoint.position.y - doubleTapTimer.tappedPos.y
                if (dx * dx + dy * dy < 50 * 50) {
                    doubleTapTimer.stop()
                    zoomAnimation.stop()
                    const loc = root.toCoordinate(eventPoint.position)
                    zoomAnimation.from = root.zoomLevel
                    zoomAnimation.to = Math.min(root.zoomLevel + 1,
                                                root.maximumZoomLevel)
                    zoomAnimation.start()
                    root.alignCoordinateToPoint(loc, eventPoint.position)
                    return
                }
            }
            doubleTapTimer.tappedPos = eventPoint.position
            doubleTapTimer.restart()
        }
    }

    DragHandler {
        id: holdZoomDrag
        target: null
        // Enabled during the double-tap detection window, while actively
        // hold-zoom-dragging, and during a pan-fallback pass.
        //
        // Pan-fallback: if the user's second press lands far from the first
        // tap (≥ 50 px), this handler has already stolen the grab from
        // AppMap's internal pan handler.  In that case we drive panning
        // ourselves via root.pan() so the gesture is not lost.
        //
        // Proximity check: only presses within 50 px of the first tap
        // are treated as double-tap-hold-drag (zoom); everything else
        // becomes a transparent pass-through pan.
        enabled: doubleTapTimer.running || root._holdZoomActive || _isPan
        grabPermissions: PointerHandler.CanTakeOverFromAnything

        property real startLevel: 0
        property real startY: 0
        property bool _isPan: false     // true when acting as pan fallback

        onActiveChanged: {
            if (active) {
                doubleTapTimer.stop()
                zoomAnimation.stop()
                // Decide: hold-drag-zoom (near first tap) or pan fallback (far)?
                const dx = centroid.position.x - doubleTapTimer.tappedPos.x
                const dy = centroid.position.y - doubleTapTimer.tappedPos.y
                if (dx * dx + dy * dy < 50 * 50) {
                    // Close to first tap → double-tap-hold-drag-zoom
                    holdZoomDrag._isPan = false
                    root._holdZoomActive = true
                    holdZoomDrag.startLevel = root.zoomLevel
                    holdZoomDrag.startY = centroid.position.y
                } else {
                    // Far from first tap → pan fallback (AppMap's pan was stolen)
                    holdZoomDrag._isPan = true
                }
            } else {
                if (root._holdZoomActive) {
                    // Zoom inertia based on vertical drag velocity
                    const vy = centroid.velocity.y
                    if (Math.abs(vy) > 50) {
                        const extraZoom = vy * 0.003
                        const targetZoom = Math.max(root.minimumZoomLevel,
                                         Math.min(root.maximumZoomLevel,
                                                  root.zoomLevel + extraZoom))
                        if (Math.abs(targetZoom - root.zoomLevel) > 0.05) {
                            zoomAnimation.from = root.zoomLevel
                            zoomAnimation.to = targetZoom
                            zoomAnimation.start()
                        }
                    }
                }
                root._holdZoomActive = false
                holdZoomDrag._isPan = false
            }
        }

        onTranslationChanged: (delta) => {
            if (root._holdZoomActive) {
                const totalDeltaY = centroid.position.y - holdZoomDrag.startY
                root.zoomLevel = Math.max(root.minimumZoomLevel,
                                 Math.min(root.maximumZoomLevel,
                                 holdZoomDrag.startLevel + totalDeltaY * 0.01))
            } else if (holdZoomDrag._isPan) {
                root.pan(-delta.x, -delta.y)
            }
        }
    }

}
