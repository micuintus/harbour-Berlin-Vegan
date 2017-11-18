import QtQuick 2.2
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.0
import QtGraphicalEffects 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

BVApp.Page {

    id: page

    property alias model: mapItemView.model
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

    BVApp.Map {
        id: map
        anchors.fill: parent
        // v-play: it is as easy as that: the copyright notice is usually displayed in the bottom left corner.
        copyrightsVisible: false

        gesture {
            enabled: true
        }

        MapItemView {
            id: mapItemView
            delegate: MapQuickItem {

                anchorPoint.x: venueMarkerImage.width / 2
                anchorPoint.y: venueMarkerImage.height

                coordinate: QtPositioning.coordinate(model.latCoord, model.longCoord)

                sourceItem: BVApp.IconButton {
                    id: venueMarkerImage
                    type: "location"

                    property var currRestaurant: mapItemView.model.item(index);
                    color: BVApp.Theme.colorFor(currRestaurant.vegan)
                    verticalAlignment: Text.AlignBottom

                    onClicked: {
                        var currRestaurant = mapItemView.model.item(index);
                        pageStack.push(Qt.resolvedUrl("VenueDescription.qml"),
                                       {
                                           restaurant     : currRestaurant,
                                           positionSource : page.positionSource
                                       });

                        // The icon parameter is only used on v-play
                        pageStack.pushAttached(Qt.resolvedUrl("VenueMapPage.qml"),
                                       {
                                           venueCoordinate: QtPositioning.coordinate(currRestaurant.latCoord,
                                                                                     currRestaurant.longCoord),
                                           positionSource: page.positionSource,
                                           name: currRestaurant.name
                                       }, BVApp.Theme.iconFor("locationarrow")
                                       );
                    }
                }
            }
        }

        Component.onCompleted: {
            addMapItem(currentPosition)
            center = currentPosition.coordinate
        }

        zoomLevel: maximumZoomLevel - (BVApp.Platform.isSailfish ? 3 : 9)
    }
}
