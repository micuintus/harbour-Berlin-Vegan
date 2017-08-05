import Sailfish.Silica 1.0
import "." as BVApp

IconButton {

    property string type
    property real scale
    property color color

    icon.source: BVApp.Theme.iconFor(type).iconString
    icon.scale: scale ? scale : 1

}
