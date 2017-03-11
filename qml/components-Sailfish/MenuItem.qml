import Sailfish.Silica 1.0 as Silica
import QtQuick 2.0

Silica.MenuItem {
    property var pageToVisit
    property var icon
    property var rootMenuItem

    onClicked: {
        if (rootMenuItem)
        {
            pageStack.replace(pageToVisit)
            pageToVisit.flickable.pullDownMenu = rootMenuItem
        }
        else
        {
            pageStack.push(pageToVisit)
        }
    }
}
