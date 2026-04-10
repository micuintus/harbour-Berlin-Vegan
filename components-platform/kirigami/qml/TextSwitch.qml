import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property string text
    property bool checked: false
    property bool automaticCheck: true
    signal userToggled()

    Controls.Label {
        Layout.fillWidth: true
        text: root.text
    }
    Controls.Switch {
        checked: root.checked
        onToggled: {
            if (root.automaticCheck)
                root.checked = checked
            root.userToggled()
        }
    }
}
