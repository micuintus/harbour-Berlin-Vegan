import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    signal activated()
    signal pushed()

    // Felgo/Sailfish pages call pageStack.pushAttached(); Kirigami's raw
    // PageRow has no such API, so pages resolve their pageStack to the
    // adapter the window exposes instead.
    property var pageStack: {
        var win = applicationWindow()
        return win && win.navStack ? win.navStack : (win ? win.pageStack : null)
    }

    // Felgo semantics: pages are created on push, so completion marks the
    // moment this page landed on the stack.
    Component.onCompleted: pushed()
}
