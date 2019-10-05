import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

import QtQuick 2.5
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.0
import QtGraphicalEffects 1.0

BVApp.Page {

    id: page

    property var model
    property var positionSource
    property alias name : page.title
    property alias map : map

    PageHeader {
        id: header
        y: 0
        title: name
        width: page.width
        z: 5
    }

    Rectangle {
        id: rectangle
        anchors.fill: header
        color: BVApp.Theme.highlightDimmerColor
        opacity: 0.6
        z: 4
    }


    property var currentPosition: MapQuickItem {
        id: currentPosition

        coordinate: positionSource.position.coordinate

        anchorPoint.x: currentPosImage.width / 2
        anchorPoint.y: currentPosImage.height / 2

        sourceItem: BVApp.IconButton {
            id: currentPosImage
            type: "cover-location"
            color: BVApp.Theme.ownLocationColor
        }
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

        gesture {
            enabled: true
        }

        // Work around QTBUG-47366;
        // remove once SFOS is on QtLocation > 5.6
        function repopulateMap() {
            // triggers a map repopulation
            mapItemView.model = 'undefined';
            mapItemView.model = page.model;
            map.dirty = false;
        }

        // Work around QTBUG-47366;
        // remove once SFOS is on QtLocation > 5.6
        Connections {
            target: mapItemView.model
            onRowsRemoved: map.dirty = true
        }

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
                    verticalAlignment: Text.AlignBottom

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("VenueDescription.qml"),
                                       {
                                           restaurant     : mapItemView.model.item(index),
                                           positionSource : page.positionSource
                                       });
                    }
                }
            }
        }

        Component.onCompleted: {
            addMapItem(currentPosition);
            centerAndZoom();
        }

        function centerAndZoom()
        {
            center = currentPosition.coordinate;
            zoomLevel = maximumZoomLevel - (BVApp.Platform.isSailfish ? 3 : 9);
        }

        BVApp.MapReCenterButton {
            // SFOS map has no 'userPositionAvailable'
            enabled: positionSource.position.coordinate.isValid

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: BVApp.Theme.paddingLarge
            anchors.bottomMargin: BVApp.Theme.paddingLarge

            onClicked: map.centerAndZoom()

            z: 6
        }
    }
}
