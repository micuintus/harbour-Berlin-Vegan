pragma Singleton

import QtQuick

QtObject {
    readonly property bool isSailfish: false
    readonly property bool isFelgo: false
    readonly property bool isKirigami: true
    readonly property bool isIos: Qt.platform.os === "ios"
    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isMacOS: Qt.platform.os === "osx"
    readonly property bool isLinux: Qt.platform.os === "linux"
    readonly property bool isDesktop: !isIos && !isAndroid
}
