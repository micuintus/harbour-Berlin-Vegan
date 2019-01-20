import VPlayApps 1.0
import QtQuick 2.5
import QtQuick.Controls 2.0 as Quick2
import BerlinVegan.components.platform 1.0 as BVApp

Quick2.RadioButton {
    id: radioButton
    implicitWidth: leftPadding + indicator.implicitWidth + spacing + contentItem.implicitWidth + rightPadding
    implicitHeight: topPadding + indicator.implicitHeight + bottomPadding
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    // align with TextSwitch implementation
    x: parent.width/6
    spacing: BVApp.Theme.paddingLarge

    // overwrite style for density-independent sizes
    contentItem: AppText {
        text: parent.text
        anchors.left: parent.left
        anchors.leftMargin: parent.indicator.width + parent.indicator.x + parent.spacing
        font.pixelSize:  BVApp.Theme.fontSizeSmall
    }

    indicator: Item {
        implicitWidth: dp(20)
        implicitHeight: dp(28)
        x: parent.leftPadding
        y: parent.height / 2 - height / 2
        Rectangle {
            anchors.centerIn: parent
            implicitWidth: BVApp.Theme.fontSizeSmall * 1.3
            implicitHeight: implicitWidth
            radius: width * 0.5
            border.color: radioButton.checked ? Theme.tintColor : Theme.secondaryTextColor
            border.width: 2

            Rectangle {
                width: parent.width * 0.5
                height: width
                anchors.centerIn: parent
                radius: width * 0.5
                color: Theme.tintColor
                visible: radioButton.checked
            }
        }
    }
}
