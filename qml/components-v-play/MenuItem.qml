import QtQuick 2.7
import VPlayApps 1.0

NavigationItem {
    id: item
    property var pageToVisit
    property alias text: item.title
    NavigationStack {
        id: stack
        initialPage: pageToVisit

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
            attachedButton.icon  = icon
        }
    }
}
