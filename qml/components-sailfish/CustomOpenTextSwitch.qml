import QtQuick 2.0
import BerlinVegan.components.platform 1.0 as BVApp
import Sailfish.Silica 1.0 as Silica

Column {
    id: item

    signal userToggled()

    property alias checked: swico.checked
    property alias automaticCheck: swico.automaticCheck

    property alias openText: swico.text
    property alias timePrefix: timeButton.label
    property alias time: timeButton.time
    signal timeSelected()
    property alias datePrefix: dateButton.label
    property alias date: dateButton.date
    signal dateSelected()

    property var locale: Qt.locale()

    width: parent.width

    Silica.TextSwitch {
        id: swico
        onClicked: item.userToggled()
    }

    Silica.ValueButton {
        id: timeButton
        property date time

        value: time.toLocaleTimeString(item.locale, Locale.ShortFormat)
        onClicked: {
            var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hour: time.getHours(),
                                        minute: time.getMinutes() });
            dialog.accepted.connect(function() {
                timeButton.time = dialog.time;
                timeSelected();
            })
        }

        anchors.leftMargin: 2 * Silica.Theme.horizontalPageMargin
        anchors.left: item.left
        anchors.right: item.right
    }

    Silica.ValueButton {
        id: dateButton
        property date date

        value: date.toLocaleDateString(item.locale, Locale.ShortFormat)
        onClicked: {
            var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: date });

            dialog.accepted.connect(function() {
                dateButton.date = dialog.date;
                dateSelected();
            })
        }

        anchors.leftMargin: 2 * Silica.Theme.horizontalPageMargin
        anchors.left: item.left
        anchors.right: item.right
    }
}
