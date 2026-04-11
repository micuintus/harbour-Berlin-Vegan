import QtQuick

// On Kirigami, page titles are handled by Kirigami.Page.title.
// This shim is invisible — it just propagates the title to the parent page.
Item {
    property string title
    property var extraContent: Item {}
    visible: false
    height: 0
    width: parent ? parent.width : 0

    onTitleChanged: {
        // Walk up to find the nearest Page and set its title
        var p = parent
        while (p) {
            if (p.hasOwnProperty("title")) {
                p.title = title
                break
            }
            p = p.parent
        }
    }
}
