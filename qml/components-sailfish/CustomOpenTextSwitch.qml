import QtQuick 2.0

Item {
    property var openText
    property var timePrefix
    property var time
    signal timeSelected()
    property var datePrefix
    property var date
    signal dateSelected()

    property var checked
    property var automaticCheck

    signal userToggled()
}
