import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    signal activated()
    signal pushed()

    // pageStack is provided natively by Kirigami when the page
    // is in the stack — no need to declare it here.
}
