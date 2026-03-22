import Felgo

import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

SimpleRow {

    id: row

    signal clicked(int index)

    property var contentWidth
    property var contentHeight

    height: contentHeight

    style.showDisclosure: false

    style.dividerColor: BVApp.Theme.dividerColor
    style.dividerLeftSpacing: 0

    Component.onCompleted: {
        row.selected.connect(clicked)
    }
}
