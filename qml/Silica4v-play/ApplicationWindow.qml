import VPlayApps 1.0

import QtQuick 2.7

import BerlinVegan.components 1.0 as BVApp

App {

    id: app

    property var cover
    property var initialPage

    Component.onCompleted: {
        // We need to access the dp() function from the Theme component
        BVApp.Theme.myApp = app
    }
}
