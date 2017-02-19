import Sailfish.Silica 1.0
import "." as BVApp

IconButton {

    property string type
    property real scale

    icon.source: BVApp.Theme.iconBy(type)
    icon.scale: scale ? scale : 1

}
