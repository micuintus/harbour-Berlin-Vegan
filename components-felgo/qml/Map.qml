import Felgo
import QtLocation
import QtQuick

AppMap {

    copyrightsVisible: false
    showUserPosition: true

    // Abstraction for gesture control.
    // Pages should use: gestureEnabled: true/false
    property bool gestureEnabled: true

    plugin:
        Plugin {
                name: "maplibregl"
                PluginParameter { name: "maplibregl.settings_template"; value: "mapbox" }
        }
    }
