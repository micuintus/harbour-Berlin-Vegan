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
            return IconType.mapmarker
        case "list":
            return IconType.list
        case "about":
            return IconType.questioncircle
        case "mapmarker":
            return IconType.mapmarker
        }
    }

    function dp(x) {
        return myApp ? myApp.dp(x) : 0
    }

    property var myApp

    // from native Android app
    readonly property color primary: "#8BC34A"

    property color primaryColor: Theme.textColor
    property color secondaryColor: Theme.secondaryTextColor
    property color highlightDimmerColor: primary
    property color highlightColor: "white"
    property color secondaryHighlightColor: Theme.listItem.dividerColor

    property int fontSizeMedium: dp(Theme.listItem.fontSizeText)
    property int fontSizeSmall: dp(Theme.listItem.fontSizeText)
    property int fontSizeExtraSmall: dp(Theme.listItem.fontSizeDetailText)
    readonly property int fontSizeLarge: dp(Theme.listItem.fontSizeText)

    readonly property int iconSizeMedium : dp(12)
    readonly property int iconSizeLarge : dp(12)

    property int paddingSmall: dp(12)
    property int paddingMedium: dp(12)
    property int paddingLarge: dp(12)
    property int horizontalPageMargin: dp(16)

    readonly property int busyIndicatorSizeLarge: 0
    readonly property int opacityRampDirection: 0
    readonly property int dividerHeight: dp(Theme.listItem.dividerHeight)
}
