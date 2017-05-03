import QtQuick 2.7
import VPlayApps 1.0

SearchBar {

    keepVisible: true
    iosAlternateStyle: true

    // this integrates better on iOS with the overall background color
    barBackgroundColor: "white"

    property Item flickableForSailfish
}
