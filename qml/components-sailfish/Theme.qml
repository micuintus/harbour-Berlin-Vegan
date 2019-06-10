pragma Singleton

import harbour.berlin.vegan 1.0
import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

QtObject {

    function venueSubTypeTagColor(type) {
        switch (type) {
        // Gastro
        case VenueModel.RestaurantFlag:
            return "#ae2e2e";
        case VenueModel.FastFoodFlag:
            return "#801877";
        case VenueModel.CafeFlag:
            return "#b88b11";
        case VenueModel.IceCreamFlag:
            return "#bd007d";
        case VenueModel.BarFlag:
            return "#6e207c";

        // Shops
        case VenueModel.FoodsFlag:
            return "#51bc36";
        case VenueModel.ClothingFlag:
            return "#5d66a3";
        case VenueModel.ToiletriesFlag:
            return "#9243a8";
        case VenueModel.SupermarketFlag:
            return "#d6bf13";
        case VenueModel.HairdressersFlag:
            return "#23858e";
        case VenueModel.SportsFlag:
            return "#2c59d3";
        case VenueModel.TattoostudioFlag:
            return "#505259";
        case VenueModel.AccommodationFlag:
            return "#b26c3e";

        case VenueModel.NoneFlag:
        default:
            return "#000000";
        }
    }

    function vegTypeColor(type) {
        switch (type) {
        case VenueModel.Vegetarian:
        case VenueModel.VegetarianVeganDeclared:
            return "#fd9827";
        case VenueModel.Vegan:
            return "#97bf0f";
        default:
            return "#f9776e";
        }
    }

    function defaultIconColor()
    {
        return (Silica.pressed
                ? highlightColor
                : primaryColor);
    }

    function iconFor(type) {
        var icon = "";

        switch (type) {
        case "answer":
            icon = "image://theme/icon-l-answer?"
            break;
        case "favorite":
            icon = "image://theme/icon-m-favorite-selected?"
            break;
        case "favorite-o":
            icon = "image://theme/icon-m-favorite?"
            break;
        case "home":
            icon = "image://theme/icon-m-home?"
            break;
        case "my_location":
            icon = "image://theme/icon-m-dot?"
            break;
        case "location":
            icon = "image://theme/icon-m-whereami?"
            break;
        case "cover-location":
            icon = "image://theme/icon-cover-location?"
            break;
        default:
            break;
        }

        return {
            iconString: icon
        }
    }

    readonly property color ownLocationColor: Silica.Theme.highlightBackgroundColor

    readonly property color primaryColor: Silica.Theme.primaryColor
    readonly property color secondaryColor: Silica.Theme.secondaryColor
    readonly property color secondaryHighlightColor: Silica.Theme.secondaryHighlightColor

    readonly property color highlightColor: Silica.Theme.highlightColor
    readonly property color highlightDimmerColor: Silica.Theme.highlightDimmerColor
    readonly property color highlightBackgroundColor: Silica.Theme.highlightBackgroundColor

    readonly property color linkColor: Silica.Theme.highlightColor
    readonly property int smallLinkFontSize: Silica.Theme.fontSizeExtraSmall

    readonly property int fontSizeMedium: Silica.Theme.fontSizeMedium
    readonly property int fontSizeExtraSmall: Silica.Theme.fontSizeExtraSmall
    readonly property int fontSizeSmall: Silica.Theme.fontSizeSmall
    readonly property int fontSizeLarge: Silica.Theme.fontSizeLarge
    readonly property int fontSizeExtraLarge: Silica.Theme.fontSizeExtraLarge

    readonly property int pageIndicatorSmall: Silica.Theme.paddingSmall
    readonly property int pageIndicatorPadding: 2*Silica.Theme.paddingLarge
    readonly property int iconToolBarPadding: 0
    readonly property color pageIndicatorColor: Silica.Theme.highlightColor

    readonly property int iconSizeMedium : Silica.Theme.iconSizeMedium
    readonly property int iconSizeLarge : Silica.Theme.iconSizeLarge

    readonly property int paddingSmall: Silica.Theme.paddingSmall
    readonly property int paddingMedium: Silica.Theme.paddingMedium
    readonly property int paddingLarge: Silica.Theme.paddingLarge

    readonly property int horizontalPageMargin: Silica.Theme.horizontalPageMargin
    readonly property int busyIndicatorSizeLarge: Silica.BusyIndicatorSize.Large

    readonly property int opacityRampLeftToRight: Silica.OpacityRamp.LeftToRight
    readonly property int opacityRampRightToLeft: Silica.OpacityRamp.RightToLeft
    readonly property int opacityRampTopToBottom: Silica.OpacityRamp.TopToBottom
    readonly property int opacityRampBottomToTop: Silica.OpacityRamp.BottomToTop

    readonly property color dividerColor: Silica.Theme.secondaryHighlightColor
    readonly property int dividerHeight: 2

    readonly property color disabledColor: "#B6B6B6"
    readonly property color warningColor: "red"

    // Silica.Theme.paddingLarge = 32 on emulator
    readonly property int mapHeight: 12.5*Silica.Theme.paddingLarge
}
