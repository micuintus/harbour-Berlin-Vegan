import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Controls.Button {
    id: btn

    leftPadding: Kirigami.Units.largeSpacing * 2
    rightPadding: Kirigami.Units.largeSpacing * 2
    topPadding: Kirigami.Units.smallSpacing + 4
    bottomPadding: Kirigami.Units.smallSpacing + 4

    background: Rectangle {
        color: btn.pressed  ? Qt.darker("#97BF0F", 1.2)
             : btn.hovered  ? Qt.lighter("#97BF0F", 1.1)
             : "#97BF0F"
        radius: Kirigami.Units.cornerRadius
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Text {
        text: btn.text
        font: btn.font
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
