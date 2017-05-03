import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

Item {
    id: abstractionItem

    property Item flickableForSailfish
    property string text

    onFlickableForSailfishChanged: {
        flickableForSailfish.header = nativeSearchField
    }

    property Component nativeSearchField: Silica.SearchField {
        id: nativeSearch
        width: abstractionItem.width
        text: abstractionItem.text

        onTextChanged: {
            if (abstractionItem.text !== text)
            {
                abstractionItem.text = text
            }
        }
    }
}
