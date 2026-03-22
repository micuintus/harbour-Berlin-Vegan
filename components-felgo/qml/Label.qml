import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

Text {
    id: root

    // truncationMode: 0 = None, 1 = Fade (mapped to Elide on Felgo), 2 = Elide
    property int truncationMode

    elide: truncationMode > 0 ? (horizontalAlignment === Text.AlignLeft ? Text.ElideRight
                                                                        : (horizontalAlignment === Text.AlignRight ? Text.ElideLeft
                                                                                                                   : Text.ElideMiddle))
                              : Text.ElideNone

    color: BVApp.Theme.primaryColor
    font.pixelSize: BVApp.Theme.fontSizeMedium
}
