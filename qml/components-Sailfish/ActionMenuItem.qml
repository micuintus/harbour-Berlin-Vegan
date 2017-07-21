import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

Silica.MenuItem {
    property var menuIcon
    property Component pageComponent
    property Page page

    onClicked: {
        pageStack.clear()
        page = pageStack.replaceAbove(null, pageComponent)
    }
}
