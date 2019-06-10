import QtQuick 2.5
import QtGraphicalEffects 1.0
import "." as BVApp

Item {
    id: centerButton
    signal clicked

    width: myLocation.width * 1.4
    height: myLocation.height * 1.4

    Rectangle {
        id: circle

        width: parent.width
        height: parent.height
        radius: width * 0.5

        color: "white"

        BVApp.IconButton {
            id: myLocation
            type: "my_location"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            onClicked: centerButton.clicked()
        }
    }

    // http://doc.qt.io/qt-5/qml-qtgraphicaleffects-dropshadow.html
    DropShadow {
        anchors.fill: circle
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: circle
    }
}
