import QtQuick 2.7
import VPlayApps 1.0

NavigationStack {
    id: stack

    navigationBar.rightBarItem: IconButtonBarItem {
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
        attachedButton.icon  = icon.iconString
    }
}
