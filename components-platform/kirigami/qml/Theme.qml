pragma Singleton

import harbour.berlin.vegan 1.0
import QtQuick
import org.kde.kirigami as Kirigami

QtObject {

    // --- Venue-specific color functions (shared logic, platform-independent) ---

    function venueSubTypeTagColor(type) {
        switch (type) {
        case VenueModel.RestaurantFlag:    return "#ae2e2e"
        case VenueModel.FastFoodFlag:      return "#801877"
        case VenueModel.CafeFlag:          return "#b88b11"
        case VenueModel.IceCreamFlag:      return "#bd007d"
        case VenueModel.BarFlag:           return "#6e207c"
        case VenueModel.FoodsFlag:         return "#51bc36"
        case VenueModel.ClothingFlag:      return "#5d66a3"
        case VenueModel.ToiletriesFlag:    return "#9243a8"
        case VenueModel.SupermarketFlag:   return "#d6bf13"
        case VenueModel.HairdressersFlag:  return "#23858e"
        case VenueModel.SportsFlag:        return "#2c59d3"
        case VenueModel.TattoostudioFlag:  return "#505259"
        case VenueModel.AccommodationFlag: return "#b26c3e"
        default:                           return "#000000"
        }
    }

    function vegTypeColor(type) {
        switch (type) {
        case VenueModel.Vegetarian:
        case VenueModel.VegetarianVeganLabeled:
            return "#fd9827"
        case VenueModel.Vegan:
            return highlightColor
        default:
            return "#f9776e"
        }
    }

    function iconFor(type) {
        var iconName = ""
        switch (type) {
        case "answer":        iconName = "call-start"; break
        case "favorite":      iconName = "starred-symbolic"; break
        case "favorite-o":    iconName = "non-starred-symbolic"; break
        case "home":          iconName = "go-home-symbolic"; break
        case "filter":        iconName = "view-filter"; break
        case "vegan":         iconName = "vegetarian-symbolic"; break
        case "my_location":   iconName = "mark-location"; break
        case "location":      iconName = "mark-location"; break
        case "cover-location": iconName = ""; break
        case "coffee":        iconName = "drink-symbolic"; break
        case "map":           iconName = "map-symbolic"; break
        case "list":          iconName = "view-list-details"; break
        case "shopping":      iconName = "shopping-cart-symbolic"; break
        case "about":         iconName = "help-about-symbolic"; break
        case "schedule":      iconName = "clock"; break
        case "details":       iconName = "documentinfo"; break
        case "accessible":    iconName = "preferences-desktop-accessibility"; break
        case "more_vert":     iconName = "overflow-menu"; break
        case "date_range":    iconName = "view-calendar"; break
        case "reset":         iconName = "edit-reset"; break
        }
        return { iconString: iconName, fontFamily: "" }
    }

    function dp(x) {
        return Math.round(x * Kirigami.Units.devicePixelRatio)
    }

    property var myApp  // unused on Kirigami, kept for API compat

    // --- Core colors (mapped from Kirigami.Theme) ---

    readonly property color primaryColor: Kirigami.Theme.textColor
    readonly property color secondaryColor: Kirigami.Theme.disabledTextColor
    readonly property color highlightDimmerColor: Kirigami.Theme.backgroundColor
    readonly property color highlightColor: "#97BF0F"  // Brand color — always green
    readonly property color secondaryHighlightColor: Kirigami.Theme.hoverColor
    readonly property color dividerColor: Kirigami.Theme.separatorColor
    readonly property color disabledColor: Kirigami.Theme.disabledTextColor
    readonly property color warningColor: Kirigami.Theme.negativeTextColor

    readonly property color linkColor: highlightColor
    readonly property color ownLocationColor: Kirigami.Theme.highlightColor

    // --- New design tokens (Kirigami-aligned) ---

    readonly property color backgroundColor: Kirigami.Theme.backgroundColor
    readonly property color surfaceColor: Kirigami.Theme.backgroundColor
    readonly property color surfaceVariantColor: Qt.darker(Kirigami.Theme.backgroundColor, 1.03)
    readonly property color foregroundColor: Kirigami.Theme.textColor
    readonly property color primaryForegroundColor: "#FFFFFF"
    readonly property color successColor: Kirigami.Theme.positiveTextColor
    readonly property color errorColor: Kirigami.Theme.negativeTextColor

    // --- Typography ---

    readonly property real fontSizeExtraLarge: Kirigami.Theme.defaultFont.pixelSize * 1.6
    readonly property real fontSizeLarge: Kirigami.Theme.defaultFont.pixelSize * 1.2
    readonly property real fontSizeMedium: Kirigami.Theme.defaultFont.pixelSize
    readonly property real fontSizeSmall: Kirigami.Theme.defaultFont.pixelSize * 0.9
    readonly property real fontSizeExtraSmall: Kirigami.Theme.defaultFont.pixelSize * 0.8
    readonly property real fontSizeTiny: Kirigami.Theme.defaultFont.pixelSize * 0.6
    readonly property real smallLinkFontSize: fontSizeTiny

    // New hierarchy names (preferred)
    readonly property real fontSizeHeadline: fontSizeExtraLarge
    readonly property real fontSizeTitle: fontSizeLarge
    readonly property real fontSizeBody: fontSizeMedium
    readonly property real fontSizeCaption: fontSizeExtraSmall
    readonly property real fontSizeOverline: fontSizeTiny

    // --- Spacing (Kirigami.Units) ---

    readonly property real paddingSmall: Kirigami.Units.smallSpacing
    readonly property real paddingMedium: Kirigami.Units.mediumSpacing
    readonly property real paddingLarge: Kirigami.Units.largeSpacing
    readonly property real horizontalPageMargin: Kirigami.Units.largeSpacing

    // New grid-aligned names (preferred)
    readonly property real smallSpacing: Kirigami.Units.smallSpacing
    readonly property real mediumSpacing: Kirigami.Units.mediumSpacing
    readonly property real largeSpacing: Kirigami.Units.largeSpacing
    readonly property real gridUnit: Kirigami.Units.gridUnit

    // --- Icons ---

    readonly property real iconSizeMedium: Kirigami.Units.iconSizes.small
    readonly property real iconSizeLarge: Kirigami.Units.iconSizes.smallMedium
    readonly property real iconSizeExtraLarge: Kirigami.Units.iconSizes.medium
    readonly property real iconToolBarPadding: Kirigami.Units.smallSpacing

    // --- Shape ---

    readonly property real cardRadius: Kirigami.Units.cornerRadius
    readonly property real buttonRadius: Kirigami.Units.cornerRadius
    readonly property real dividerHeight: 1

    // --- Page indicators ---

    readonly property real pageIndicatorSmall: Kirigami.Units.smallSpacing
    readonly property real pageIndicatorPadding: Kirigami.Units.smallSpacing
    readonly property color pageIndicatorColor: "white"

    readonly property real busyIndicatorSizeLarge: Kirigami.Units.iconSizes.large

    // --- Opacity ramp (Sailfish compat, unused on Kirigami) ---

    readonly property int opacityRampLeftToRight: 0
    readonly property int opacityRampRightToLeft: 1
    readonly property int opacityRampTopToBottom: 2
    readonly property int opacityRampBottomToTop: 3

    // --- Component-specific tokens ---

    readonly property real sectionHeaderIconLeftPadding: Kirigami.Units.smallSpacing
    readonly property real sectionHeaderIconTextPadding: Kirigami.Units.mediumSpacing

    readonly property real customOpenButtonVerticalMargin: 1
    readonly property real customOpenButtonHorizontalMargin: Kirigami.Units.smallSpacing
    readonly property real customOpenButtonVerticalPadding: 2

    readonly property real mapHeight: Kirigami.Units.gridUnit * 12

    readonly property color venueListNameColor: secondaryColor
    readonly property real venueListNameFontSize: fontSizeLarge
    readonly property real descriptionHeaderHeightRatio: 1.0 / 3.0
    readonly property color streetLabelColor: secondaryColor
    readonly property bool showSeparatorBeforeTags: true
    readonly property real tagCloudTopMargin: paddingMedium
    readonly property real mapTopMargin: paddingMedium
    readonly property real filterPageTopSpacing: 2 * paddingLarge
    readonly property real filterPagePostCategorySpacing: 0
    readonly property string headerImageSuffix: ".jpg"
    readonly property bool headerBarOverlapsImage: false
}
