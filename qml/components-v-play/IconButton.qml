import VPlayApps 1.0

IconButton {

    function iconBy(type) {
        switch (type) {
        case "answer":
            return IconType.phone
        case "favorite":
            return IconType.hearto
        case "home":
            return IconType.home
        case "location":
            return IconType.mapmarker
        }
    }

    property string type
    property real scale

    icon: iconBy(type)

}
