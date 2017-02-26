import VPlayApps 1.0
import "." as BVApp

IconButton {

    property string type
    property real scale

    icon: BVApp.Theme.iconBy(type)
    // dp(22) = 29 on 1334 x 750 (iPhone 6/6S)
    size: scale ? dp(22) * scale : dp(22)

}
