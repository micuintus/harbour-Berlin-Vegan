import VPlayApps 1.0

import QtQuick 2.7

import BerlinVegan.components 1.0 as BVApp

App {

    id: app

    property var initialPage
    property var cover

    NavigationStack {
        id: navigationStack
        initialPage: app.initialPage
    }

    Component.onCompleted: {
        // We need to access the dp() function from the Theme component
        BVApp.Theme.myApp = app
    }

}
