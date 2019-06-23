import QtQuick 2.7
import Felgo 3.0
import BerlinVegan.components.platform 1.0 as BVApp

Row {

    property alias text: appText.text
    property alias checked: swico.checked
    spacing: parent.spacing
    x: parent.width/6

    AppText {
        id: appText
        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
        anchors.verticalCenter: parent.verticalCenter
    }

    AppSwitch {
      id: swico
      height: appText.height
  }
}
