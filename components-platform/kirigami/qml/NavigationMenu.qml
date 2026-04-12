import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.GlobalDrawer {
    id: drawer

    // On desktop: isMenu:true renders actions as a compact dropdown in the toolbar
    // (standard Kirigami desktop UX).  On Android: isMenu:false gives a proper
    // side-drawer that slides in from the left.
    isMenu: Qt.platform.os !== "android"

    // modal:true forces the hamburger button to appear in the toolbar on desktop
    // (without it Kirigami may hide the button and show a persistent sidebar).
    // On Android, modal:true also keeps the drawer dismissible by tapping outside.
    modal: true

    default property alias menuItems: drawer.actions

    // Compat: Felgo uses headerView, Kirigami uses header
    property alias headerView: drawer.header

    // Compat: Felgo navigation bar offset
    property real navigationBarOffset: 0

    // Self-register as the window's globalDrawer
    Component.onCompleted: {
        var win = applicationWindow()
        if (win)
            win.globalDrawer = drawer
    }
}
