import VPlayApps 1.0

import QtQuick 2.7

import "." as SilicaComponents

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
        SilicaComponents.Theme.myApp = app
    }

}
