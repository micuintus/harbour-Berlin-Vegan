import QtQuick

import BerlinVegan.components.platform 1.0 as BVApp

Text {
    id: root

    // TruncationMode values: None=0, Elide=1, Fade=2
    // On Felgo, Fade is treated as clip (no shader). Only Elide mode enables text elide.
    // Important: do NOT enable elide for Fade mode - it creates a circular dependency
    // when width is derived from contentWidth (contentWidth becomes 0 with elide + width=0).
    property int truncationMode

    elide: truncationMode === 1 ? (horizontalAlignment === Text.AlignLeft ? Text.ElideRight
                                                                          : (horizontalAlignment === Text.AlignRight ? Text.ElideLeft
                                                                                                                     : Text.ElideMiddle))
                                : Text.ElideNone

    clip: truncationMode > 0

    color: BVApp.Theme.primaryColor
    font.pixelSize: BVApp.Theme.fontSizeMedium
}
