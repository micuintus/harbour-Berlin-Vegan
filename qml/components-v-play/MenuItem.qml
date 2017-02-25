import QtQuick 2.7
import VPlayApps 1.0

NavigationItem {
    id: item
    property var pageToVisit
    property alias text: item.title
    NavigationStack {
        initialPage: pageToVisit
    }
}
