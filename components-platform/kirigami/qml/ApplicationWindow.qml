import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: app

    property var initialPage
    property var cover  // unused on Kirigami (Sailfish only)
    property var globalPositionSource

    // Adapter that pages reach via Page.pageStack: it carries the
    // Sailfish/Felgo navigation API (pushAttached etc.) that the raw
    // Kirigami PageRow lacks.
    NavigationStackWithPushAttached {
        id: navStack
        initialPage: app.initialPage
    }
    readonly property alias navStack: navStack

    Component.onCompleted: {
        // Find NavigationMenu (GlobalDrawer) child and assign it
        for (var i = 0; i < app.data.length; i++) {
            if (app.data[i] instanceof Kirigami.GlobalDrawer) {
                app.globalDrawer = app.data[i]
                break
            }
        }
        if (initialPage)
            pageStack.push(initialPage)
    }
}
