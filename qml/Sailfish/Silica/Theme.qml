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

    property int fontSizeMedium: dp(Theme.listItem.fontSizeText)
    property int fontSizeExtraSmall: dp(Theme.listItem.fontSizeDetailText)

    property int paddingSmall: dp(10)
    property int horizontalPageMargin: dp(15)

}
