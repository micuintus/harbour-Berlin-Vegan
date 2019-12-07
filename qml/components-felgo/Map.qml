import Felgo 3.0
import QtLocation 5.9

AppMap {

    // the copyright notice is usually displayed in the bottom left corner
    copyrightsVisible: false

    // V-Play 2.15.1: Fix user position and location circle for AppMap with MapBoxGL plugin
    showUserPosition: true

    plugin: Plugin {
        name: "mapboxgl"
        parameters: [ PluginParameter {
                name: "mapboxgl.access_token"
                value: "pk.eyJ1IjoibWljdSIsImEiOiJjaXdxd2MzcW4wMDBrMnlxZHc1cmtzdnhjIn0.a2u7IrIYN1kGCue-BU8zEg"
        }]
    }
}
