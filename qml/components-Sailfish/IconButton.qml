import Sailfish.Silica 1.0
import "." as BVApp

IconButton {
    function iconBy(type) {
        switch (type) {
        case "answer":
            return "image://theme/icon-l-answer?"+ (pressed
                                                     ? BVApp.Theme.highlightColor
                                                     : BVApp.Theme.primaryColor)
        case "favorite":
            return "image://theme/icon-m-favorite?" + (pressed
                                                       ? BVApp.Theme.highlightColor
                                                       : BVApp.Theme.primaryColor)
        case "home":
            return "image://theme/icon-m-home?" + (pressed
                                                   ? BVApp.Theme.highlightColor
                                                   : BVApp.Theme.primaryColor)
        case "location":
            return "image://theme/icon-m-location?" + BVApp.Theme.highlightBackgroundColor
        }
    }

    property string type
    property real scale

    icon.source: iconBy(type)
    icon.scale: scale ? scale : 1

}
