import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.GlobalDrawer {
    id: drawer

    // isMenu: true renders actions as a popup menu (not a persistent sidebar).
    // modal: true forces the hamburger button to appear in the toolbar on desktop
    // (without it Kirigami may hide the button assuming a windowed layout).
    isMenu: true
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
