import Felgo

import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

App {

    id: app

    property var cover
    property Component initialPage

    onInitTheme: {
        // Navigation bar (green Berlin-Vegan branding)
        Theme.navigationBar.backgroundColor = BVApp.Theme.highlightColor
        Theme.navigationBar.titleColor = "white"
        Theme.navigationBar.itemColor = "white"

        // App-wide colors
        Theme.colors.tintColor = BVApp.Theme.highlightColor
        Theme.colors.backgroundColor = "white"
        Theme.colors.secondaryBackgroundColor = "#F5F5F5"
        Theme.colors.textColor = BVApp.Theme.primaryColor

        // Status bar
        Theme.colors.statusBarStyle = Theme.colors.statusBarStyleWhite
    }

    FontLoader {
        id: material
        source: "qrc:/icons/MaterialIcons-Regular.ttf"
    }

    Component.onCompleted: {
        // Lock to portrait on mobile
        if (!BVApp.Platform.isMacOS && typeof nativeUtils !== "undefined") {
            nativeUtils.preferredScreenOrientation = NativeUtils.ScreenOrientationPortrait;
        }
        BVApp.Theme.myApp = app
        if (material.status == FontLoader.Ready) {
            console.log("Loaded font: '" + material.name + "'")
        } else {
            console.error("Could not load font: '" + material.name + "'")
        }
    }
}
