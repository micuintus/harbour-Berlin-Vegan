import Sailfish.Silica 1.0 as Silica
import "." as BVApp

Silica.IconButton {
    property string type
    property real iconScale: 1
    property color color: BVApp.Theme.defaultIconColor()
    property int verticalAlignment

    // Dummy on SailfishOS
    property string text

    icon.source: BVApp.Theme.iconFor(type).iconString + color
    icon.scale: iconScale
}
