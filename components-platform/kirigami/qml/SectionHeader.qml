import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property string text
    property var icon
    property string iconSource

    spacing: 0
    width: parent ? parent.width : implicitWidth

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: root.icon && root.icon.iconString && root.icon.iconString.length > 0
            source: root.icon ? (root.icon.iconString || "") : ""
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            Layout.alignment: Qt.AlignVCenter
            color: "#97BF0F"
        }

        Kirigami.Heading {
            Layout.fillWidth: true
            level: 4
            text: root.text
            color: "#97BF0F"
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing
        opacity: 0.4
    }
}
