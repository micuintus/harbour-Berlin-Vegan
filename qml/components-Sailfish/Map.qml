import QtPositioning 5.2
import MapboxMap 1.0

MapboxMap {
    id: theMap
    // styleUrl: "http://localhost:8553/v1/mbgl/style"
    // introduced in Qt 5.7
    property var copyrightsVisible
    // plugin : Plugin { name: "osm" }
    MapboxMapGestureArea {
        map: theMap
    }
    center: QtPositioning.coordinate(60.170448, 24.942046) // Helsinki

    accessToken: "pk.eyJ1IjoibWljdSIsImEiOiJjaXdxd2MzcW4wMDBrMnlxZHc1cmtzdnhjIn0.a2u7IrIYN1kGCue-BU8zEg"

    styleUrl: "mapbox://styles/mapbox/streets-v10"
    zoomLevel: maximumZoomLevel - 1
    cacheDatabaseStoreSettings: true
    cacheDatabaseDefaultPath: true

    Componont.onCompleted: {
        map.addImagePath("position-icon", Qt.resolvedUrl("icons/position"));
        map.setLayoutProperty(constants.layerPois, "icon-image", constants.imagePoi);
    }

    property QtObject defines: QtObject {

           property string sourcePois: "pm-source-pois"

   }
}
