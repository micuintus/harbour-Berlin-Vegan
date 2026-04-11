import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.GlobalDrawer {
    id: drawer
    isMenu: true
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
