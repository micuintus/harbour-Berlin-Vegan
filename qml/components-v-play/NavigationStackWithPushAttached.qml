import QtQuick 2.7
import VPlayApps 1.0

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
}
