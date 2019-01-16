pragma Singleton

import harbour.berlin.vegan 1.0
import QtQuick 2.7
import VPlayApps 1.0

QtObject {

    function colorFor(type) {
        switch (type) {
        case VenueModel.Vegetarian:
        case VenueModel.VegetarianVeganDeclared:
            return "#fd9827";
        case VenueModel.Vegan:
            return highlightColor;
        default:
            return "#f9776e";
        }
    }

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
        case "vegan":
            icon       = "\ue900";
            fontFamily = "icomoon";
            break;
        case "my_location":
            icon = "my_location";
            break;
        case "location":
            icon = "place";
            break;
        case "cover-location":
            // needs to be empty in favour of 'showUserPosition'. we still use 'currentPostion' for calculation placement and zoom level of the map.
            icon = "";
            break;
        case "coffee":
            icon       = IconType.coffee;
            fontFamily = "FontAwesome";
            break;
        case "map":
            icon = "map";
            break;
        case "list":
            icon = "view_list";
            break;
        case "shopping":
            icon = "shopping_cart";
            break;
        case "about":
            icon = "info";
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

    readonly property color ownLocationColor: "blue"

    readonly property color primaryColor: "#212121"
    readonly property color secondaryColor: "#727272"
    readonly property color highlightDimmerColor: "white"
    readonly property color highlightColor: "#97BF0F"
    readonly property color secondaryHighlightColor: "#E4E4E4"
    readonly property color dividerColor: "#B6B6B6"
    readonly property color disabledColor: Theme.disabledColor
    readonly property color warningColor: "red"

    readonly property color linkColor: highlightColor
    readonly property real smallLinkFontSize: dp(12)

    readonly property real fontSizeMedium: dp(17)
    readonly property real fontSizeSmall: dp(14.6) // Theme.listItem.fontSizeText
    readonly property real fontSizeExtraSmall: dp(13.2) // Theme.listItem.fontSizeDetailText
    readonly property real fontSizeTiny: dp(8.6)
    readonly property real fontSizeLarge: fontSizeMedium
    readonly property real fontSizeExtraLarge: dp(23)

    readonly property real pageIndicatorSmall: dp(6)
    readonly property real pageIndicatorPadding: dp(6)
    readonly property color pageIndicatorColor: "white"

    // HACK: only used in IconToolBar so far, we want to keep scale at 1 ATM
    readonly property real iconSizeMedium: dp(22.9)
    readonly property real iconSizeLarge: dp(22.9)
    readonly property real iconSizeExtraLarge: dp(28)

    readonly property real paddingSmall: dp(5.2)
    readonly property real paddingMedium: dp(10)
    readonly property real paddingLarge: fontSizeSmall
    readonly property real horizontalPageMargin: paddingLarge

    readonly property real sectionHeaderIconLeftPadding: dp(2)
    readonly property real sectionHeaderIconTextPadding: dp(10.7)
    readonly property real busyIndicatorSizeLarge: 0

    readonly property real iconToolBarPadding: dp(3.6)


    // From OpacityRampEffectBase.qml:
    //     LtR = 0, RtL = 1, TtB = 2, BtT = 3
    //     property int direction: 0 // default = LeftToRight-OpaqueToTranslucentLtR = 0, RtL = 1, TtB = 2, BtT = 3
    readonly property int opacityRampLeftToRight: 0
    readonly property int opacityRampRightToLeft: 1
    readonly property int opacityRampTopToBottom: 2
    readonly property int opacityRampBottomToTop: 3

    readonly property real dividerHeight: dp(1)

    readonly property real mapHeight: dp(200)
}
