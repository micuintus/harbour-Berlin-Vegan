import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

NavigationItem {
    id: item
    property var menuIcon
    property alias text: item.title
    property Component pageComponent
    property Page currentPage

    icon: menuIcon.iconString

    Component.onCompleted: {
        iconFont = menuIcon.fontFamily
    }

    function loadPage() {
        if (pageComponent && navigationStack)
        {
            navigationStack.push(pageComponent);
            currentPage = navigationStack.getPage(0);
            console.log(currentPage)
        }
    }

    onLoaded: { console.log("loaded!"); loadPage(); }
    onNavigationStackChanged: { console.log("NavigationStackChanged!"); loadPage(); }
    onPageComponentChanged: {console.log("pageComponentChanged!"); loadPage(); }


    BVApp.NavigationStackWithPushAttached
    {  }


    onSelected: {
        navigationStack.popAllExceptFirst()
    }
}
