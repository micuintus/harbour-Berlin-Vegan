import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Action {
    property var menuIcon
    property var pageComponent
    property bool split: false
    property var splitViewExtraPageComponent

    signal menuActivated()

    icon.name: menuIcon ? (menuIcon.iconString || menuIcon) : ""
    onTriggered: {
        menuActivated()
        if (pageComponent) {
            applicationWindow().pageStack.clear()
            applicationWindow().pageStack.push(pageComponent)
        }
    }
}
