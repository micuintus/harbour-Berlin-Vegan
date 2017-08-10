pragma Singleton

import QtQuick 2.7
import VPlayApps 1.0

QtObject {

    readonly property bool isSailfish: false
    readonly property bool isVPlay: true

    readonly property bool isIos:   Theme.isIos
    readonly property bool isMacOS: Theme.isOSX
}
