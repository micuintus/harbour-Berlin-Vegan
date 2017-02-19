import VPlayApps 1.0
import "." as BVApp

IconButton {

    property string type
    property real scale

    icon: BVApp.Theme.iconBy(type)

}
