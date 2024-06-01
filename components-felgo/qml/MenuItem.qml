import QtQuick 2.7
import Felgo
import BerlinVegan.components.platform 1.0 as BVApp

NavigationItem {
    id: item
    property var menuIcon
    property Component pageComponent
    property Component splitViewExtraPageComponent

    property bool split: false
    signal clicked

    // Outside should only read it
    property Page page

    iconType: menuIcon.iconString

    BVApp.NavigationStackWithPushAttached
    {
        Timer {
            id: pushExtraContentLater
            interval: 5;
            repeat: false
            onTriggered: push(splitViewExtraPageComponent)
        }

        splitView: tablet && landscape && split
        leftColumnWidth: screenWidth/2.2
        onSplitViewActiveChanged: {
            if (!splitViewActive && depth === 2)
            {
                popAllExceptFirst();
            }
            else if (splitViewExtraPageComponent && depth == 1)
            {
                // HACK to fix Felgo problem with "stuck" page that appears
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

    onNavigationStackChanged: tryLoadPage()
    onPageComponentChanged: tryLoadPage()
    onSelected: {
        tryLoadPage();
        clicked();
    }

}
