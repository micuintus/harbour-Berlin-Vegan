import QtQuick 2.2

import Sailfish.Silica 1.0 as Silica

Silica.DetailItem {
    property int fontWeight: Font.Normal
    readonly property int   fontSize: children[0].font.pixelSize
    readonly property color labelColor: children[0].color
    readonly property color valueColor: children[1].color

    Component.onCompleted:
    {
        children[0].font.weight = fontWeight
        children[1].font.weight = fontWeight
    }
}
