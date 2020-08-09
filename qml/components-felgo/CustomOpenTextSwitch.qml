import QtQuick 2.7
import Felgo 3.0
import BerlinVegan.components.platform 1.0 as BVApp
import QtQml 2.11

MouseArea {
    id: item

    property alias openText: openText.text
    property alias timePrefix: timePrefix.text
    property alias time: timePicker.time
    signal timeSelected()
    property alias datePrefix: datePrefix.text
    property date date
    signal dateSelected()

    property alias checked: swico.checked
    property alias automaticCheck: swico.updateChecked
    signal userToggled()
    onClicked: userToggled()

    property var locale: Qt.locale()

    height: 2 * (timeButton.height + anchors.topMargin + anchors.bottomMargin)

    anchors.topMargin: BVApp.Theme.paddingSmall
    anchors.bottomMargin: BVApp.Theme.paddingSmall
    anchors.left: parent.left
    anchors.right: parent.right

    AppText {
        id: openText
        font.pixelSize: BVApp.Theme.fontSizeSmall
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: item.anchors.topMargin

        anchors.leftMargin: BVApp.Theme.horizontalPageMargin + BVApp.Theme.sectionHeaderIconLeftPadding + BVApp.Theme.fontSizeSmall * 1.05 + BVApp.Theme.sectionHeaderIconTextPadding
    }

    AppText {
        id: timePrefix
        font.pixelSize: BVApp.Theme.fontSizeSmall

        anchors.left: openText.right
        anchors.leftMargin: BVApp.Theme.horizontalPageMargin
        anchors.verticalCenter: timeButton.verticalCenter
        anchors.topMargin: BVApp.Theme.paddingSmall
    }

    AppButton
    {
        id: timeButton
        z: 2 // required to force time picker dialog on top

        BVApp.TimePickerDialog {
            id: timePicker
            onAccepted: timeSelected()
        }

        text: item.time.toLocaleTimeString(item.locale, Locale.ShortFormat)
        onClicked: timePicker.openWith(timePicker.time)

        anchors.left: timePrefix.right
        anchors.leftMargin: BVApp.Theme.paddingSmall
        anchors.verticalCenter: openText.verticalCenter


        // -> button layout
        flat: false
        textSize: BVApp.Theme.fontSizeExtraSmall
        minimumHeight: 1
        minimumWidth: 1
        horizontalMargin: BVApp.Theme.customOpenButtonHorizontalMargin
        verticalMargin: BVApp.Theme.customOpenButtonVerticalMargin
        verticalPadding: BVApp.Theme.customOpenButtonVerticalPadding
        // <- button layout
    }

    AppText {
        id: datePrefix
        font.pixelSize: BVApp.Theme.fontSizeSmall

        anchors.top: timePrefix.bottom
        anchors.topMargin: item.anchors.topMargin + item.anchors.bottomMargin
        anchors.right: timePrefix.right
    }

    AppButton
    {
        id: dateButton

        text: item.date.toLocaleDateString(item.locale, Locale.ShortFormat)
        onClicked: nativeUtils.displayDatePicker(item.date)

        Connections {
            target: nativeUtils
            onDatePickerFinished: {
                   if (accepted)
                   {
                       item.date = date
                       item.dateSelected();
                   }
            }
        }

        anchors.left: timeButton.left
        anchors.verticalCenter: datePrefix.verticalCenter

        // -> button layout
        flat: false
        textSize: BVApp.Theme.fontSizeExtraSmall
        minimumHeight: 1
        minimumWidth: 1
        horizontalMargin: BVApp.Theme.customOpenButtonHorizontalMargin
        verticalMargin: BVApp.Theme.customOpenButtonVerticalMargin
        verticalPadding: BVApp.Theme.customOpenButtonVerticalPadding
        // <- button layout
    }

    AppSwitch {
        id: swico
        height: openText.height
        dropShadow: true

        anchors.right: parent.right
        anchors.verticalCenter:  openText.verticalCenter
        anchors.rightMargin: BVApp.Theme.horizontalPageMargin

        onToggled: userToggled()
    }
}
