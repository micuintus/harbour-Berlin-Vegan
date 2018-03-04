import Sailfish.Silica 1.0 as Silica
import QtQuick 2.2

Silica.Page {
    id: page
    property string title
    signal pushed

    Connections {
        target: pageContainer
        onCurrentPageChanged: {
            if (pageContainer.currentPage === page)
            {
                page.pushed();
            }
        }
    }
}
