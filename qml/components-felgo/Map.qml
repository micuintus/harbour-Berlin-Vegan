import Felgo
import QtLocation 5.9

AppMap {

    // the copyright notice is usually displayed in the bottom left corner
    copyrightsVisible: false

    // V-Play 2.15.1: Fix user position and location circle for AppMap with MapBoxGL plugin
    showUserPosition: true

    plugin: Plugin { name: "mapboxgl" }
}
