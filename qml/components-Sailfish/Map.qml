import QtLocation 5.0
import MapboxMap 1.0
import QtPositioning 5.3

MapboxMap {
    id: map
     MapboxMapGestureArea {
        map: map
}
      center: QtPositioning.coordinate(60.170448, 24.942046)
            zoomLevel: 4.0
            minimumZoomLevel: 0
            maximumZoomLevel: 20
            pixelRatio: 3.0

            accessToken: "pk.eyJ1IjoibWljdSIsImEiOiJjaXdxd2MzcW4wMDBrMnlxZHc1cmtzdnhjIn0.a2u7IrIYN1kGCue-BU8zEg"
            cacheDatabaseMaximalSize: 20*1024*1024
            cacheDatabasePath: "/tmp/mbgl-cache.db"

    styleUrl: "mapbox://styles/mapbox/outdoors-v10"
}
