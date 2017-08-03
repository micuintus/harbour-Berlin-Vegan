import VPlayApps 1.0

import QtQuick 2.7

import BerlinVegan.components.platform 1.0 as BVApp

App {

    id: app

    property var cover
    property var initialPage

    onInitTheme: {
        Theme.navigationBar.backgroundColor = BVApp.Theme.highlightColor
        Theme.navigationBar.titleColor = "white"
        // otherwise tintColor is used (see below) and you might have a hard time seeing navigation
        Theme.navigationBar.itemColor = Theme.navigationBar.titleColor
        // accent color, e.g. for icons
        Theme.colors.tintColor = BVApp.Theme.highlightColor
        // otherwise it's greyish on iOS
        Theme.colors.secondaryBackgroundColor = "white"
        // we need white text in the status bar, because of the Berlin-Vegan green
        Theme.colors.statusBarStyle = Theme.colors.statusBarStyleWhite
    }

    FontLoader {
        id: material
        source: "qrc:/icons/MaterialIcons-Regular.ttf"
    }

    Component.onCompleted: {
        // We need to access the dp() function from the Theme component
        BVApp.Theme.myApp = app
        if (material.status == FontLoader.Ready) {
            console.log("Loaded font: '" + material.name + "'")
        } else {
            console.error("Could not load font: '" + material.name + "'")
        }
    }
}
