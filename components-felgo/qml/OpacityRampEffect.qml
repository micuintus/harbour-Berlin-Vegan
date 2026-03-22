import QtQuick

// No-op on Felgo. OpacityRampEffect is a Sailfish Silica visual effect
// for gradient text fade. On Felgo this is unused (always disabled).
Item {
    property Item sourceItem
    property bool enabled: false
    property int direction: 0
    property real offset: 0.5
    property real slope: 2.0

    visible: false
}
