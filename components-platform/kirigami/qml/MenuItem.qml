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

    icon.name: menuIcon ? (menuIcon.iconString || menuIcon) : ""
    onTriggered: {
        menuActivated()
        if (pageComponent) {
            var win = applicationWindow()
            if (win && win.pageStack) {
                win.pageStack.clear()
                root.page = win.pageStack.push(pageComponent)
            }
        }
    }

    // Navigation stack for this menu item (compatibility)
    // Returns the application pageStack, not an internal one
    property var navigationStack: applicationWindow() ? applicationWindow().pageStack : null
}
