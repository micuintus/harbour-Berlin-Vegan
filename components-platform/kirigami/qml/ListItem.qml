import QtQuick
import QtQuick.Controls as Controls

Controls.ItemDelegate {
    id: listItem
    property var contentWidth
    property var contentHeight

    height: contentHeight || implicitHeight
}
