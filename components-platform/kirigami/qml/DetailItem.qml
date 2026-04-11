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

    spacing: Kirigami.Units.largeSpacing

    Text {
        id: labelText
        Layout.preferredWidth: parent.width * 0.4
        Layout.maximumWidth: parent.width * 0.4
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