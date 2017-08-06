import QtQuick 2.7
import VPlayApps 1.0

import BerlinVegan.components.platform 1.0 as BVApp

NavigationStack {
    id: stack

    navigationBar.rightBarItem: TextButtonBarItem {
        id: attachedButton

        property var attachedPage
        property var props
        property var attachedTo

        visible: attachedPage !== undefined
                 && attachedTo === stack.currentPage
        onClicked: {
            if (visible)
            {
                stack.push(attachedPage, props)
            }
        }
    }

    function pushAttached(page, props, icon)
    {
        attachedButton.attachedTo = stack.currentPage
        attachedButton.attachedPage = page
        attachedButton.props = props
        attachedButton.text = icon.iconString
        attachedButton.textItem.font.family = icon.fontFamily
        attachedButton.textItem.font.pixelSize = BVApp.Theme.iconSizeExtraLarge
    }
}
