import Sailfish.Silica 1.0 as Silica
import "." as BVApp

Silica.IconButton {

    property string type
    property real scale
    property color color: BVApp.Theme.defaultIconColor()
    property int verticalAlignment


    icon.source: BVApp.Theme.iconFor(type).iconString + color
    icon.scale: scale ? scale : 1

}
