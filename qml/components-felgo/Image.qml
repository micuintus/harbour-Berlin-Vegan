import QtQuick 2.7
import Felgo

Image {

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // do not make the place holder image fullscreen
            if (!source.toString().includes("Platzhalter_v2_mitSchriftzug")) {
                 PictureViewer.show(app, source)
            }
        }
    }
}
