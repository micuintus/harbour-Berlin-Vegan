import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

Silica.MenuItem {
    property var icon
    property Page page: parent.parent.menuPage
}
