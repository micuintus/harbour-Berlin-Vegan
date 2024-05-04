import Felgo
import QtLocation

AppMap {

    // the copyright notice is usually displayed in the bottom left corner
    copyrightsVisible: false

    // V-Play 2.15.1: Fix user position and location circle for AppMap with MapBoxGL plugin
    showUserPosition: true

    plugin:
        Plugin {
                name: "maplibregl"
                PluginParameter { name: "maplibregl.settings_template"; value: "mapbox" }
        }
    }

