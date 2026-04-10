import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    signal activated()
    signal pushed()

    // Compat: Felgo/Sailfish use these for navigation
    property var pageStack: Kirigami.ApplicationWindow.pageStack
}
