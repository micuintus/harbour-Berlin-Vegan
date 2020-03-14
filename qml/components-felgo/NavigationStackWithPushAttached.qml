import QtQuick 2.7
import QtQuick.Window 2.7
import Felgo 3.0

import BerlinVegan.components.platform 1.0 as BVApp

NavigationStack {
    id: stack

    property Component buton: Component { TextButtonBarItem {
        property var attachedPage
        property var props

        onClicked: stack.push(attachedPage, props);
    } }

    function pushAttached(page, props, icon)
    {
        var attachedButton = buton.createObject(stack,
        {
            "attachedPage"            : page,
            "props"                   : props,
            "text"                    : icon.iconString,
            "textItem.font.family"    : icon.fontFamily,
            "textItem.font.pixelSize" : Qt.binding(function() { return BVApp.Theme.iconSizeExtraLarge })
        });

        stack.currentPage.rightBarItem = attachedButton;
    }

    Component.onCompleted: {
        // This hotfixes a faulty navigation bar height on Android after enabling the default Qt high dpi support in main.cpp:
        if (!BVApp.Platform.isAndroid) {
            return
        }
        // Before the next line "navigationBar.height = 139.97597452201887" on my test device.
        anchors.topMargin = 1
        // The line above triggers something so that the "navigationBar.height = 55.97597452201887", but now it is partly hidden
        // by the status bar on Android, so we add "Theme.statusBarHeight" but taking the high dpi scaling factor into account.
        navigationBar.height += Theme.statusBarHeight / Screen.devicePixelRatio
        // Afterwards the "navigationBar.height = 79.96567788859839". Next we reset the anchor again to its default value.
        anchors.topMargin = 0
        // As comparison: without high dpi "navigationBar.height = 56" and "Theme.statusBarHeight = 24" on my test device.
    }
}
