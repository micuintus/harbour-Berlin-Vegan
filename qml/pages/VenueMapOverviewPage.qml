import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.ui 1.0 as BVApp

import QtQuick
import QtLocation
import QtPositioning
import Qt5Compat.GraphicalEffects

BVApp.Page {

    id: page

    property var model
    property var positionSource   // kept for VenueDescription distance calc
    property alias name : page.title
    property alias map : map

    BVApp.PageHeader {
        id: header
        y: 0
        title: name
        width: parent.width
        z: 5
    }

    Rectangle {
        id: rectangle
        anchors.fill: header
        color: BVApp.Theme.highlightDimmerColor
        opacity: 0.6
        z: 4
    }

    FastBlur {
        anchors.fill: header
        source: ShaderEffectSource {
            sourceItem: map
            sourceRect: Qt.rect(0, 0, header.width, header.height)
        }
        radius: 40
        transparentBorder: true
        z: 3
    }

    onActivated: if (map.dirty) map.repopulateMap()

    BVApp.Map {
        id: map
        anchors.fill: parent
        // Work around QTBUG-47366;
        // remove once SFOS is on QtLocation > 5.6
        property bool dirty: false

        gestureEnabled: true

        // Work around QTBUG-47366;
        // remove once SFOS is on QtLocation > 5.6
        function repopulateMap() {
            mapItemView.model = 'undefined';
            mapItemView.model = page.model;
            map.dirty = false;
        }

        // Work around QTBUG-47366;
        // remove once SFOS is on QtLocation > 5.6
        Connections {
            target: mapItemView.model
            function onRowsRemoved() { map.dirty = true }
        }

        // Venue markers
        MapItemView {
            id: mapItemView
            model: page.model

            delegate: MapQuickItem {

                anchorPoint.x: venueMarkerImage.width / 2
                anchorPoint.y: venueMarkerImage.height

                coordinate: QtPositioning.coordinate(model.latCoord, model.longCoord)

                sourceItem: BVApp.IconButton {
                    id: venueMarkerImage
                    type: "location"

                    color: BVApp.Theme.vegTypeColor(model.vegan)
                    opacity: (typeof model.dataSource !== "undefined" && model.dataSource === "osm") ? 0.5 : 1.0
                    verticalAlignment: Text.AlignBottom

                    onClicked: {
                        if (!map.gestureActive) {
                            pageStack.push(Qt.resolvedUrl("VenueDescription.qml"),
                                           {
                                               restaurant     : mapItemView.model.item(index),
                                               positionSource : page.positionSource
                                           });
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            centerAndZoom()
        }

        // Fly to user position on page open.
        // Use AppMap.userPosition (set by showUserPosition: true) rather than
        // the external PositionSource so we don't depend on permission timing.
        function centerAndZoom() {
            if (map.userPositionAvailable)
                animateToLocation(map.userPosition.coordinate, 15)
        }

        function animateToLocation(coord, targetZoom) {
            flyAnimation.stop();
            flyAnimation.fromCenter = map.center;
            flyAnimation.toCenter = coord;
            flyAnimation.fromZoom = map.zoomLevel;
            flyAnimation.toZoom = targetZoom;
            flyAnimation.start();
        }

        ParallelAnimation {
            id: flyAnimation
            property var fromCenter: QtPositioning.coordinate(0, 0)
            property var toCenter: QtPositioning.coordinate(0, 0)
            property real fromZoom: 10
            property real toZoom: 15

            CoordinateAnimation {
                target: map
                property: "center"
                from: flyAnimation.fromCenter
                to: flyAnimation.toCenter
                duration: 600
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: map
                property: "zoomLevel"
                from: flyAnimation.fromZoom
                to: flyAnimation.toZoom
                duration: 600
                easing.type: Easing.InOutQuad
            }
        }

        BVApp.MapReCenterButton {
            // AppMap.userPositionAvailable tracks whether showUserPosition
            // has acquired a fix — no separate PositionSource needed here.
            enabled: map.userPositionAvailable

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: BVApp.Theme.paddingLarge
            anchors.bottomMargin: BVApp.Theme.paddingLarge
                                  + (typeof nativeUtils !== "undefined" ? nativeUtils.safeAreaInsets.bottom : 0)

            onClicked: map.centerAndZoom()

            z: 6
        }
    }
}
