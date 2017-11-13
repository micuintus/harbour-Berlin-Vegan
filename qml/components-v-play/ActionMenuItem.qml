import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

BVApp.MenuItem {
    signal clicked
    onSelected: clicked()
}
