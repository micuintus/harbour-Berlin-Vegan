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

    BVApp.NavigationStackWithPushAttached
    {  }

    function tryLoadPage() {
        if (pageComponent && navigationStack)
        {
            navigationStack.push(pageComponent);
            page = navigationStack.getPage(0);
        }
    }

    Component.onCompleted: {
        iconFont = menuIcon.fontFamily
        tryLoadPage();
    }

    onLoaded: tryLoadPage()
    onNavigationStackChanged: tryLoadPage()
    onPageComponentChanged: tryLoadPage()


    onSelected: {
        if (navigationStack)
        {
            navigationStack.popAllExceptFirst();
        }
    }
}
