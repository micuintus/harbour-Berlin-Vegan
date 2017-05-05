import QtQuick 2.7
import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

BVApp.MenuItem {
    property Component pageComponent
    onPageComponentChanged:
    {
        page = pageComponent.createObject()
    }

    signal clicked

    onSelected: clicked()
}
