import Felgo

import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

SimpleRow {

    id: row

    signal clicked(int index)

    property var contentWidth
    property var contentHeight
    property bool dividerVisible: true

    height: contentHeight

    style.showDisclosure: false

    style.dividerColor: dividerVisible ? BVApp.Theme.dividerColor : "transparent"
    style.dividerLeftSpacing: 0

    Component.onCompleted: {
        row.selected.connect(clicked)
    }
}
