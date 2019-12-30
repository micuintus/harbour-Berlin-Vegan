import Felgo 3.0

import QtQuick 2.7

import BerlinVegan.components.platform 1.0 as BVApp

App {

    id: app

    licenseKey: "A44C173C13EE5B173A91385819136062089D8EA1DBA647ACC817145E026DF7D40974A4E762F1EF6136C24CFBE91565346DB2BF6775DCBB0FDBFE793A3B146A83C4C13A0430D49860DAEACED818D34A23B408D306F18D7F7DA50D2516318EBE5BACE5D1A7B93032066943D2F73D2F3E9760622B229FC596C331FAC3BB36A487425A6D26BC207C3C45BFB235F841EDA78B4D02C5695D9334DE4C79CEDEEF399B6AB31B2B2E982CBBAD15E221B6C484E4C334E1AC9C725C06D1B6BDC6E2099BC261CAFEDC243349492FE4019DEBFED28C6C324077C5A5370C8A54E40C4A392D94EC02E11ADE1A8B40F5E81A9564C5BE42B4F421B014FD6C5434FFE450315134120D5FC5261282B2F6B14F8F6665F69910E546B8FA1A706E7ECF7CD95153C86F9B70D8701FF55A0ACD8A76EACBADD3F93074"

    property var cover
    property Component initialPage

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

    onTabletChanged: {
        nativeUtils.preferredScreenOrientation = tablet ? NativeUtils.ScreenOrientationUnspecified :
                                                          NativeUtils.ScreenOrientationPortrait
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
