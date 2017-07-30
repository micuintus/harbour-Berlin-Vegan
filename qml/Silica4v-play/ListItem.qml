import VPlayApps 1.0

import QtQuick 2.7

import BerlinVegan.components.platform 1.0 as BVApp

SimpleRow {

    id: row

    signal clicked(int index)

    property var contentWidth
    property var contentHeight

    height: contentHeight

    // Do not show right angle in iOS
    style.showDisclosure: false

    // Divider
    style.dividerColor: BVApp.Theme.dividerColor
    style.dividerLeftSpacing: 0

    Component.onCompleted: {
        row.selected.connect(clicked)
    }
}
