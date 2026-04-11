import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    property string label
    property string value
    property int fontWeight: Font.Normal

    spacing: Kirigami.Units.largeSpacing

    Text {
        Layout.preferredWidth: parent.width * 0.4
        Layout.maximumWidth: parent.width * 0.4
        text: label
        color: Kirigami.Theme.disabledTextColor
        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
        font.weight: fontWeight
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
    }

    Text {
        Layout.fillWidth: true
        text: value
        color: Kirigami.Theme.textColor
        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 0.9
        font.weight: fontWeight
        wrapMode: Text.WordWrap
    }
}
