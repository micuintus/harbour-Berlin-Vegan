pragma Singleton

import harbour.berlin.vegan 1.0
import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

QtObject {

    function colorFor(type) {
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
            icon = "image://theme/icon-m-location?"
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
