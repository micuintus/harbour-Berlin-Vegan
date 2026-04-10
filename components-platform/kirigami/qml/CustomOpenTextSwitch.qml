import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property alias openText: openLabel.text
    property string timePrefix
    property var time: new Date()
    signal timeSelected()
    property string datePrefix
    property date date: new Date()
    signal dateSelected()

    property bool checked: false
    property bool automaticCheck: true
    signal userToggled()

    spacing: Kirigami.Units.smallSpacing

    RowLayout {
        Layout.fillWidth: true

        Controls.Label {
            id: openLabel
            Layout.fillWidth: true
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

    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Controls.Label { text: root.timePrefix }
        Controls.Button {
            text: root.time.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
            onClicked: {
                var t = new Date(root.time)
                t.setHours((t.getHours() + 1) % 24)
                root.time = t
                root.timeSelected()
            }
        }

        Controls.Label { text: root.datePrefix }
        Controls.Button {
            text: root.date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
            onClicked: {
                var d = new Date(root.date)
                d.setDate(d.getDate() + 1)
                root.date = d
                root.dateSelected()
            }
        }
    }
}
