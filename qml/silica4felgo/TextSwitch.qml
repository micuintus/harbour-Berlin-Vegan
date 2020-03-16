import QtQuick 2.7
import Felgo 3.0
import BerlinVegan.components.platform 1.0 as BVApp

MouseArea {
    id: mouseArea

    property alias text: appText.text
    property alias checked: swico.checked
    height: appText.height + anchors.topMargin + anchors.bottomMargin

    onClicked: swico.toggle()

    anchors.topMargin: BVApp.Theme.paddingSmall
    anchors.bottomMargin: BVApp.Theme.paddingSmall
    anchors.left: parent.left
    anchors.right: parent.right

    AppText {
        id: appText
        font.pixelSize: BVApp.Theme.fontSizeSmall
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: swico.left

        anchors.leftMargin: BVApp.Theme.horizontalPageMargin + BVApp.Theme.sectionHeaderIconLeftPadding  + BVApp.Theme.fontSizeSmall * 1.05 + BVApp.Theme.sectionHeaderIconTextPadding

    }

    AppSwitch {
      id: swico
      height: appText.height
      dropShadow: true
      anchors.right: parent.right
      anchors.bottom: parent.bottom

      anchors.rightMargin: BVApp.Theme.horizontalPageMargin
  }
}
