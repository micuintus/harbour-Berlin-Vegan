import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

Silica.MenuItem {
    property Page page
    property Component pageComponent

    // dummies
    property Component splitViewExtraPageComponent
    property bool split
    property var menuIcon

    onClicked: page = pageStack.push(pageComponent)
}
