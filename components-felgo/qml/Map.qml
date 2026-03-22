import Felgo
import QtLocation
import QtQuick

AppMap {

    copyrightsVisible: false
    showUserPosition: true

    // Compatibility shim: Qt Location Map has a 'gesture' group property.
    // AppMap doesn't expose it, so we provide a dummy object.
    property QtObject gesture: QtObject {
        property bool enabled: true
    }

    plugin:
        Plugin {
                name: "maplibregl"
                PluginParameter { name: "maplibregl.settings_template"; value: "mapbox" }
        }
    }
