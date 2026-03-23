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

        // Navigation drawer (white background, clean Material look)
        if (Theme.navigationDrawer) {
            Theme.navigationDrawer.backgroundColor = "white"
            Theme.navigationDrawer.textColor = BVApp.Theme.primaryColor
            Theme.navigationDrawer.activeTextColor = BVApp.Theme.highlightColor
        }
    }

    FontLoader {
        id: material
        source: "qrc:/icons/MaterialIcons-Regular.ttf"
    }

    onTabletChanged: {
        nativeUtils.preferredScreenOrientation = tablet ? NativeUtils.ScreenOrientationUnspecified :
                                                          NativeUtils.ScreenOrientationPortrait
    }

    Component.onCompleted: {
        BVApp.Theme.myApp = app
        if (material.status == FontLoader.Ready) {
            console.log("Loaded font: '" + material.name + "'")
        } else {
            console.error("Could not load font: '" + material.name + "'")
        }
    }
}
