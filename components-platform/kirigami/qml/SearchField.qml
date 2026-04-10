import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.SearchField {
    id: searchField
    property string placeHolderText: ""
    property var flickableForSailfish
    property alias textField: searchField
    placeholderText: placeHolderText
}
