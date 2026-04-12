import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Action {
    property var menuIcon
    property var pageComponent
    property var page
    property bool split: false

    signal menuActivated()

    // menuIcon is {iconString, fontFamily} from Theme.iconFor().
    // Set both icon.name (KDE theme lookup) and icon.source (Kirigami built-in
    // fallback) so icons appear on platforms without the full Breeze theme.
    icon.name: menuIcon ? (menuIcon.iconString || menuIcon) : ""

    onTriggered: {
        menuActivated()
        if (pageComponent) {
            applicationWindow().pageStack.clear()
            applicationWindow().pageStack.push(pageComponent)
        }
    }
}
