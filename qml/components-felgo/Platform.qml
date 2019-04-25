pragma Singleton

import QtQuick 2.7
import Felgo 3.0

QtObject {

    readonly property bool isSailfish:  false
    readonly property bool isFelgo:     true

    readonly property bool isAndroid:   Theme.isAndroid
    readonly property bool isIos:       Theme.isIos
    readonly property bool isMacOS:     Theme.isOSX
}
