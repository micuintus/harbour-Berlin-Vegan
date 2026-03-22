import QtLocation 5.0

Map {

    property bool gestureEnabled: true
    gesture.enabled: gestureEnabled

    plugin : Plugin { name: "osm" }
}
