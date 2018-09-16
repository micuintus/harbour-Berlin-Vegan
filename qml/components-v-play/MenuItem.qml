import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

NavigationItem {
    id: item
    property var menuIcon
    property alias text: item.title
    property Component pageComponent
    property Component splitViewExtraPageComponent

    property bool split: false

    // Outside should only read it
    property Page page

    icon: menuIcon.iconString

    BVApp.NavigationStackWithPushAttached
    {
        splitView: tablet && split
        leftColumnWidth: screenWidth/2.2
    }

    function tryLoadPage() {
        if (pageComponent && navigationStack)
        {
            navigationStack.clearAndPush(pageComponent);
            page = navigationStack.getPage(0);

            if (splitViewExtraPageComponent && navigationStack.splitViewActive)
            {
                navigationStack.push(splitViewExtraPageComponent);
            }

        }
    }

    Component.onCompleted: {
        iconFont = menuIcon.fontFamily
        tryLoadPage();
    }

    onLoaded: tryLoadPage()
    onNavigationStackChanged: tryLoadPage()
    onPageComponentChanged: tryLoadPage()
    onSelected: tryLoadPage()

}
