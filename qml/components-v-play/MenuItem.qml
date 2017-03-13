import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

NavigationItem {
    id: item
    property var pageToVisit
    property alias text: item.title

    BVApp.NavigationStackWithPushAttached
    {
        initialPage: pageToVisit
    }

    Component.onCompleted: {
        item.iconFont = "Material Icons"
    }
}
