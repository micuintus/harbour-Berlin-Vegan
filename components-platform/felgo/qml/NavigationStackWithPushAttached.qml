import QtQuick 2.7
import QtQuick.Window 2.7
import Felgo

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
        // Hotfix: Felgo miscalculates NavigationBar height on Android with Qt high DPI.
        // Setting topMargin briefly triggers a layout recalculation that corrects it.
        if (!BVApp.Platform.isAndroid) {
            return
        }
        var heightBefore = navigationBar.height
        anchors.topMargin = 1
        // On some devices with Qt high DPI, the topMargin trick corrects a
        // doubled height.  When that happens the status bar inset is lost and
        // must be re-added.  On devices where the height is already correct
        // (includes the status bar), add a small visual padding.
        if (navigationBar.height < heightBefore) {
            navigationBar.height += nativeUtils.safeAreaInsets.top
        } else {
            navigationBar.height += nativeUtils.safeAreaInsets.top * 0.3
        }
        anchors.topMargin = 0
    }
}
