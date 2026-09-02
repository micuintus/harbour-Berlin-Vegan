import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    signal activated()
    signal pushed()

    // pageStack is provided natively by Kirigami when the page
    // is in the stack — no need to declare it here.

    // Felgo semantics: pages are created on push, so completion marks the
    // moment this page landed on the stack.
    Component.onCompleted: pushed()
}
