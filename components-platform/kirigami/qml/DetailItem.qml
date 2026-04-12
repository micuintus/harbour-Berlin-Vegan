import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: root
    property string label
    property string value
    property int fontWeight: Font.Normal

    // Exposed for API compatibility with Felgo/Sailfish
    property alias fontSize: labelText.font.pixelSize
    property alias valueColor: valueText.color
    readonly property real leftMargin: Kirigami.Units.largeSpacing
    readonly property real rightMargin: Kirigami.Units.largeSpacing

    // Explicit width is required so that the RowLayout gets a proper size
    // regardless of whether it is a ListView delegate (ListView sets width
    // automatically) or a direct Column child (no automatic width propagation).
    // Without this, Layout.preferredWidth: parent.width * 0.4 creates a
    // circular binding that resolves to 0, making all text invisible.
    width: parent ? parent.width : implicitWidth

    spacing: Kirigami.Units.largeSpacing

    Text {
        id: labelText
        Layout.preferredWidth: root.width * 0.4
        Layout.maximumWidth: root.width * 0.4
        text: root.label
        color: Kirigami.Theme.disabledTextColor
        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
        font.weight: root.fontWeight
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
    }

    Text {
        id: valueText
        Layout.fillWidth: true
        text: root.value
        color: Kirigami.Theme.textColor
        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
        font.weight: root.fontWeight
        wrapMode: Text.Wrap
    }
}
