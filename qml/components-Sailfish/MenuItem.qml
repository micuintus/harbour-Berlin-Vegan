import Sailfish.Silica 1.0 as Silica
import QtQuick 2.0

Silica.MenuItem {
    property var pageToVisit
    property var icon

    onClicked: pageStack.push(pageToVisit)
}
