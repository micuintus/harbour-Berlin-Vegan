import Felgo

import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

App {

    id: app

    property var cover
    property Component initialPage

    onInitTheme: {
        Theme.navigationBar.backgroundColor = BVApp.Theme.highlightColor
        Theme.navigationBar.titleColor = "white"
        Theme.navigationBar.itemColor = Theme.navigationBar.titleColor
        Theme.colors.tintColor = BVApp.Theme.highlightColor
        Theme.colors.secondaryBackgroundColor = "white"
        Theme.colors.statusBarStyle = Theme.colors.statusBarStyleWhite
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
