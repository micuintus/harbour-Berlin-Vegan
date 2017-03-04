pragma Singleton

import QtQuick 2.7
import VPlayApps 1.0

QtObject {

    function iconBy(type) {
        switch (type) {
        case "answer":
            return IconType.phone
        case "favorite":
            return IconType.hearto
        case "home":
            return IconType.home
        case "location":
        case "cover-location":
            return IconType.mapmarker
        case "list":
            return IconType.list
        case "about":
            return IconType.questioncircle
        case "locationarrow":
            return IconType.locationarrow
        }
    }

    function dp(x) {
        return myApp ? myApp.dp(x) : 0
    }

    property var myApp

    readonly property color primaryColor: Theme.textColor
    readonly property color secondaryColor: Theme.secondaryTextColor
    // from native Android app
    readonly property color highlightDimmerColor: "#8BC34A"
    readonly property color highlightColor: "white"
    readonly property color secondaryHighlightColor: Theme.listItem.dividerColor

    readonly property color linkColor: highlightDimmerColor

    readonly property int fontSizeMedium: dp(Theme.listItem.fontSizeText)
    readonly property int fontSizeSmall: dp(Theme.listItem.fontSizeText)
    readonly property int fontSizeExtraSmall: dp(Theme.listItem.fontSizeDetailText)
    readonly property int fontSizeLarge: dp(Theme.listItem.fontSizeText)

    readonly property int iconSizeMedium : dp(12)
    readonly property int iconSizeLarge : dp(12)

    readonly property int paddingSmall: dp(12)
    readonly property int paddingMedium: dp(12)
    readonly property int paddingLarge: dp(12)
    readonly property int horizontalPageMargin: dp(16)

    readonly property int busyIndicatorSizeLarge: 0
    readonly property int opacityRampDirection: 0
    readonly property int dividerHeight: dp(Theme.listItem.dividerHeight)
}
