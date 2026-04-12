import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: root
    property string text
    property bool checked: false
    property bool automaticCheck: true
    signal userToggled()

    width: parent ? parent.width : implicitWidth
    spacing: 0

    Controls.Label {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        text: root.text
        wrapMode: Text.WordWrap
    }

    Controls.Switch {
        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        Layout.rightMargin: Kirigami.Units.mediumSpacing
        checked: root.checked
        onToggled: {
            if (root.automaticCheck)
                root.checked = checked
            root.userToggled()
        }
    }
}
