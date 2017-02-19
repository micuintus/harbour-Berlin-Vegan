pragma Singleton

import QtQuick 2.7
import VPlayApps 1.0

QtObject {

    function dp(x) {
        return myApp ? myApp.dp(x) : 0
    }

    property var myApp

    property color primaryColor: Theme.textColor
    property color secondaryColor: Theme.secondaryTextColor
    property color highlightDimmerColor: "white"
    property color highlightColor: Theme.secondaryTextColor
    property color secondaryHighlightColor: Theme.listItem.dividerColor

    property int fontSizeMedium: dp(Theme.listItem.fontSizeText)
    property int fontSizeSmall: dp(Theme.listItem.fontSizeText)
    property int fontSizeExtraSmall: dp(Theme.listItem.fontSizeDetailText)

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
