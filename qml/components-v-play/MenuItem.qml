import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

NavigationItem {
    id: item
    property var page
    property var menuIcon
    property alias text: item.title

    icon: menuIcon.iconString

    Component.onCompleted: {
        iconFont = menuIcon.fontFamily
    }

    BVApp.NavigationStackWithPushAttached
    {
        initialPage: page
    }
}
