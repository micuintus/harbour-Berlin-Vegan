import Felgo
import QtLocation
import QtQuick

AppMap {

    copyrightsVisible: false
    showUserPosition: true

    property bool gestureEnabled: true

    plugin: Plugin {
        name: "maplibre"
        parameters: [
            PluginParameter {
                name: "maplibre.map.styles"
                value: "https://tiles.openfreemap.org/styles/liberty"
            }
        ]
    }
}
