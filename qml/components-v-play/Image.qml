import QtQuick 2.7
import VPlayApps 1.0

Image {

    MouseArea {
        anchors.fill: parent
        onClicked: {
            PictureViewer.show(app, source)
        }
    }
}
