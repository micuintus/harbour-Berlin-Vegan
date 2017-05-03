import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

Silica.PullDownMenu {
    id: menu

    property Page menuPage
    flickable: menuPage.flickable

    // Always keep the menu on the current root page
    data: [
    Connections {
        target: pageStack
        onDepthChanged: {

            if (    "undefined" !== typeof(pageStack.currentPage)
                 && "undefined" !== typeof(pageStack.currentPage.flickable)
                 && pageStack.depth === 1)
            {
                menuPage = pageStack.currentPage
            }
        }
    }]
}

