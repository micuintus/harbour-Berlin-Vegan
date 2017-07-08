import QtLocation 5.0

Map {

    // introduced in Qt 5.7
    property var copyrightsVisible
    plugin : Plugin { name: "osm" }
}
