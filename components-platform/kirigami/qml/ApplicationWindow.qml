import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: app

    property var initialPage
    property var cover  // unused on Kirigami (Sailfish only)
    property var globalPositionSource

    Component.onCompleted: {
        if (initialPage)
            pageStack.push(initialPage)
        if (typeof app.onApplicationStarted === "function")
            app.onApplicationStarted()
    }
}
