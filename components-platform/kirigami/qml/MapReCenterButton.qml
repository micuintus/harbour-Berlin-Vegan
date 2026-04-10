import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Controls.RoundButton {
    icon.name: "mark-location"
    icon.color: Kirigami.Theme.textColor
    width: Kirigami.Units.gridUnit * 3
    height: width

    background: Rectangle {
        radius: width / 2
        color: Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.separatorColor
        border.width: 1
        opacity: 0.9
    }
}
