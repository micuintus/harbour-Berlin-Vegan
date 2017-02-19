pragma Singleton

import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

QtObject {

    function iconBy(type) {
        switch (type) {
        case "answer":
            return "image://theme/icon-l-answer?"+ (Silica.pressed
                                                     ? Silica.Theme.highlightColor
                                                     : Silica.Theme.primaryColor)
        case "favorite":
            return "image://theme/icon-m-favorite?" + (Silica.pressed
                                                       ? Silica.Theme.highlightColor
                                                       : Silica.Theme.primaryColor)
        case "home":
            return "image://theme/icon-m-home?" + (Silica.pressed
                                                   ? Silica.Theme.highlightColor
                                                   : Silica.Theme.primaryColor)
        case "location":
            return "image://theme/icon-m-location?" + Silica.Theme.highlightBackgroundColor
        }
    }

    readonly property color primaryColor: Silica.Theme.primaryColor
    readonly property color secondaryColor: Silica.Theme.secondaryColor
    readonly property color secondaryHighlightColor: Silica.Theme.secondaryHighlightColor

    readonly property color highlightColor: Silica.Theme.highlightColor
    readonly property color highlightDimmerColor: Silica.Theme.highlightDimmerColor
    readonly property color highlightBackgroundColor: Silica.Theme.highlightBackgroundColor

    readonly property int fontSizeMedium: Silica.Theme.fontSizeMedium
    readonly property int fontSizeExtraSmall: Silica.Theme.fontSizeExtraSmall
    readonly property int fontSizeSmall: Silica.Theme.fontSizeSmall

    readonly property int iconSizeMedium : Silica.Theme.iconSizeMedium
    readonly property int iconSizeLarge : Silica.Theme.iconSizeLarge

    readonly property int paddingSmall: Silica.Theme.paddingSmall
    readonly property int paddingMedium: Silica.Theme.paddingMedium
    readonly property int paddingLarge: Silica.Theme.paddingLarge

    readonly property int horizontalPageMargin: Silica.Theme.horizontalPageMargin
    readonly property int busyIndicatorSizeLarge: Silica.BusyIndicatorSize.Large
    readonly property int opacityRampDirection: Silica.OpacityRamp.TopToBottom
    readonly property int dividerHeight: 2
}
