import QtQuick 2.2
import Sailfish.Silica 1.0
import QtPositioning 5.2

import "../components/distance.js" as Distance


Item {


    PositionSource {
        id: positionSource
    }

    Component.onCompleted: {
        positionSource.start()
    }

    property string name
    property string street
    property var restaurantCoordinate
    property var pictures
    property real shrinkHeightBy


    Image {
        id: image

        source: typeof pictures !== "undefined"
                ? pictures[0].url
                : ""
        fillMode: Image.PreserveAspectCrop

        height: Math.max(parent.height - shrinkHeightBy,0)

        // This eads to the effect that the image is being cropped
        // from both bottom and top by half a pixel per shrinkHeightBy
        y: shrinkHeightBy
    }

    Rectangle {
        property int xMargin: 10
        property int yMargin: 7
        x: nameLabel.extraContent.x + nameLabel.extraContent.width - xMargin
        y: nameLabel.y + nameLabel.childrenRect.y - yMargin - shrinkHeightBy * 0.1
        height: nameLabel.childrenRect.height + yMargin*2
        width: (nameLabel.childrenRect.width - nameLabel.extraContent.width) + xMargin*2
        radius: 5
        color: Theme.highlightDimmerColor
        opacity: 0.6
    }

    PageHeader {
        id: nameLabel
        readonly property int initalY: 100

        title : name
        y: initalY + shrinkHeightBy * 0.5
    }

    Rectangle {
        anchors {
            top: streetLabel.top
            left: image.left
            right: image.right
            bottom: image.bottom
        }

        color: Theme.highlightDimmerColor

        // relative to parent opacity!
        opacity: 0.6
    }

    Label {
        id: streetLabel
        text: street
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.highlightColor
        truncationMode: TruncationMode.Fade

        anchors {
            left: image.left
            right: distanceLabel.left
            margins: Theme.paddingLarge
        }

        y: parent.height - height
    }

    Label {
        id: distanceLabel
        text: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods
              ? Distance.humanReadableDistanceString(positionSource.position.coordinate,
                                                               restaurantCoordinate)
              : ""
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.highlightColor

        anchors {
            right: parent.right
            margins:  Theme.paddingLarge
        }

        y: parent.height - height
    }
}

