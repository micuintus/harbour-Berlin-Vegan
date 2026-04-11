import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Action {
    id: root
    property var menuIcon
    property var pageComponent
    property bool split: false
    property var splitViewExtraPageComponent

    // Reference to the created page (for compatibility)
    property var page: null

    signal menuActivated()
    signal pageChanged()

    icon.name: menuIcon ? (menuIcon.iconString || menuIcon) : ""
    onTriggered: {
        menuActivated()
        if (pageComponent) {
            var win = applicationWindow()
            if (win && win.pageStack) {
                win.pageStack.clear()
                root.page = win.pageStack.push(pageComponent)
                pageChanged()
            }
        }
    }

    // Navigation stack for this menu item (compatibility)
    property var navigationStack: navStack

    BVApp.NavigationStackWithPushAttached {
        id: navStack
    }
}
