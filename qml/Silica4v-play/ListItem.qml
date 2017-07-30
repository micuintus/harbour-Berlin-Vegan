import VPlayApps 1.0

import QtQuick 2.7

SimpleRow {

    id: row

    signal clicked(int index)

    property var contentWidth
    property var contentHeight

    height: contentHeight

    // Do not show right angle in iOS
    style.showDisclosure: false


    Component.onCompleted: {
        row.selected.connect(clicked)
    }
}
