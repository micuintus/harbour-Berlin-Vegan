pragma Singleton

import QtQuick 2.7
import VPlayApps 1.0

QtObject {

    function iconFor(type) {
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
        case "filter":
            icon = "filter_list";
            break;
        case "leaf":
            icon       = IconType.leaf;
            fontFamily = "FontAwesome";
            break;
        case "location":
        case "cover-location":
            icon = "place";
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
            icon = "directions";
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

    readonly property color primaryColor: "#212121"
    readonly property color secondaryColor: "#727272"
    readonly property color highlightDimmerColor: "white"
    readonly property color highlightColor: "#97BF0F"
    readonly property color secondaryHighlightColor: "#E4E4E4"
    readonly property color dividerColor: "#B6B6B6"

    readonly property color linkColor: highlightColor

    readonly property int fontSizeMedium: dp(17)
    readonly property int fontSizeSmall: dp(16) // Theme.listItem.fontSizeText
    readonly property int fontSizeExtraSmall: dp(15) // Theme.listItem.fontSizeDetailText
    readonly property int fontSizeLarge: dp(18)

    readonly property int iconSizeMedium : dp(12)
    readonly property int iconSizeLarge : dp(12)
    readonly property int iconSizeExtraLarge : dp(32)

    readonly property int paddingSmall: dp(6)
    readonly property int paddingMedium: dp(11)
    readonly property int paddingLarge: dp(15)
    readonly property int horizontalPageMargin: dp(15)

    readonly property int busyIndicatorSizeLarge: 0

    // From OpacityRampEffectBase.qml:
    //     LtR = 0, RtL = 1, TtB = 2, BtT = 3
    //     property int direction: 0 // default = LeftToRight-OpaqueToTranslucentLtR = 0, RtL = 1, TtB = 2, BtT = 3
    readonly property int opacityRampLeftToRight: 0
    readonly property int opacityRampRightToLeft: 1
    readonly property int opacityRampTopToBottom: 2
    readonly property int opacityRampBottomToTop: 3

    readonly property int dividerHeight: dp(1)
}
