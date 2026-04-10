import QtQuick
import org.kde.kirigami as Kirigami

// On Kirigami, page titles are handled by Kirigami.Page.title.
// This is a compat shim that renders as a heading when used standalone.
Kirigami.Heading {
    level: 2
    property string title: text
    property var extraContent: Item {}
    text: title
    padding: Kirigami.Units.largeSpacing
}
