import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property string text
    property bool checked: false
    property bool automaticCheck: true
    signal userToggled()

    // Align all switches at 40% width, labels take remaining space
    Controls.Label {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        text: root.text
        wrapMode: Text.WordWrap
    }
    Controls.Switch {
        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        checked: root.checked
        onToggled: {
            if (root.automaticCheck)
                root.checked = checked
            root.userToggled()
        }
    }
}
