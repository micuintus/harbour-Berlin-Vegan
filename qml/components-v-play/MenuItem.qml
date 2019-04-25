import QtQuick 2.7
import Felgo 3.0
import BerlinVegan.components.platform 1.0 as BVApp

NavigationItem {
    id: item
    property var menuIcon
    property alias text: item.title
    property Component pageComponent
    property Component splitViewExtraPageComponent

    property bool split: false
    signal clicked

    // Outside should only read it
    property Page page

    icon: menuIcon.iconString

    BVApp.NavigationStackWithPushAttached
    {
        Timer {
            id: pushExtraContentLater
            interval: 5;
            repeat: false
            onTriggered: push(splitViewExtraPageComponent)
        }

        splitView: tablet && split
        leftColumnWidth: screenWidth/2.2
        onSplitViewActiveChanged: {
            if (!splitViewActive && depth === 2)
            {
                popAllExceptFirst();
            }
            else if (splitViewExtraPageComponent && depth == 1)
            {
                // HACK to fix V-Play problem with "stuck" page that appears
                // with the iOS animations otherwise
                pushExtraContentLater.start();

            }
        }
    }

    function tryLoadPage() {
        if (pageComponent && navigationStack)
        {
            navigationStack.clearAndPush(pageComponent);
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
        tryLoadPage();
        clicked();
    }

}
