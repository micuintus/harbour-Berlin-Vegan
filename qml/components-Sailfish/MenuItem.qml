import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

Silica.MenuItem {
    property var page
    property var icon

    onClicked: pageStack.push(page)
}
