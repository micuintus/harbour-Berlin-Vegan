import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: app

    property var initialPage
    property var cover  // unused on Kirigami (Sailfish only)
    property var globalPositionSource

    pageStack.initialPage: initialPage

    Component.onCompleted: {
        if (typeof app.onApplicationStarted === "function")
            app.onApplicationStarted()
    }
}
