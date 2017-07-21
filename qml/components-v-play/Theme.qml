pragma Singleton

import QtQuick 2.7
import VPlayApps 1.0

QtObject {

    function iconBy(type) {
        // default
        var fontFamily = "Material Icons";
        var icon = "";

        switch (type) {
        case "answer":
            icon = "phone";
            break;
        case "favorite":
            icon = "star";
            break;
        case "favorite-o":
            icon = "star_border";
            break;
        case "home":
            icon = "public";
            break;
        case "leaf":
            return IconType.leaf
        case "location":
        case "cover-location":
            icon = "location_on";
            break;
        case "food":
            icon = "restaurant_menu";
            break;
        case "shopping":
            icon = "shopping_cart";
            break;
        case "about":
            icon = "info";
            break;
        case "locationarrow":
            icon       = IconType.locationarrow;
            fontFamily = "FontAwesome";
            break;
        case "schedule":
            icon = "schedule";
            break;
        case "details":
            icon = "details";
            break;
        case "accessible":
            icon = "accessible";
            break;
        case "more_vert":
            icon = "more_vert";
            break;
        }

        return {
            iconString: icon,
            fontFamily: fontFamily
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

    // From OpacityRampEffectBase.qml:
    //     LtR = 0, RtL = 1, TtB = 2, BtT = 3
    //     property int direction: 0 // default = LeftToRight-OpaqueToTranslucentLtR = 0, RtL = 1, TtB = 2, BtT = 3
    readonly property int opacityRampLeftToRight: 0
    readonly property int opacityRampRightToLeft: 1
    readonly property int opacityRampTopToBottom: 2
    readonly property int opacityRampBottomToTop: 3

    readonly property int dividerHeight: dp(Theme.listItem.dividerHeight)
}
