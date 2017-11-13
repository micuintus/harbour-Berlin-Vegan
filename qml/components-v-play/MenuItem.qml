import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

NavigationItem {
    id: item
    property var menuIcon
    property alias text: item.title
    property Component pageComponent
    property Page page

    icon: menuIcon.iconString

    Component.onCompleted: {
        iconFont = menuIcon.fontFamily
    }

    BVApp.NavigationStackWithPushAttached
    {  }

    onLoaded:
    {
        if (pageComponent)
        {
            navigationStack.push(pageComponent);
            page = navigationStack.getPage(0);
        }
    }


    onSelected: {
        navigationStack.popAllExceptFirst()
    }
}
