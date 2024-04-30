import Sailfish.Silica 1.0 as Silica
import QtQuick 2.5

Silica.MenuItem {
    property Component pageComponent
    property Page page

    // Dummies
    property Component splitViewExtraPageComponent
    property bool split
    property var menuIcon

    onClicked: {
        pageStack.clear()
        page = pageStack.replaceAbove(null, pageComponent)
    }
}
