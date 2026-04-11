import QtQuick
import QtQuick.Controls as Controls

Controls.Label {
    // Compat: Felgo/Sailfish TruncationMode (0=None, 1=Fade, 2=Elide)
    // On Kirigami we map all truncation modes to standard elide.
    property int truncationMode: 0
    elide: truncationMode > 0 ? Text.ElideRight : Text.ElideNone
    clip: true
}
