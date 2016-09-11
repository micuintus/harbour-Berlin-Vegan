import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.nemomobile.dbus 2.0
import Sailfish.Silica 1.0

Column {
    property var restaurant

    id: column


    DBusInterface {
        id: voicecall

        service: "com.jolla.voicecall.ui"
        path: "/"
        iface: "com.jolla.voicecall.ui"

        function dial(number) {
            call('dial', number)
        }
    }

    Separator {
        width: column.width
        horizontalAlignment: Qt.AlignCenter
        color: Theme.secondaryHighlightColor
        height: 2
    }

    RowLayout {
        id: row
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Layout.maximumWidth: column.width/3

        width: column.width

        IconButton {
            icon.source: "image://theme/icon-l-answer?" + (pressed
                         ? Theme.highlightColor
                         : Theme.primaryColor)
            icon.scale: Theme.iconSizeMedium / Theme.iconSizeLarge

            onClicked: voicecall.dial(restaurant.telephone)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        IconButton {
            icon.source: "image://theme/icon-m-favorite?" + (pressed
                         ? Theme.highlightColor
                         : Theme.primaryColor)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }


        IconButton {
            icon.source: "image://theme/icon-m-home?" + (pressed
                         ? Theme.highlightColor
                         : Theme.primaryColor)

            onClicked: Qt.openUrlExternally(restaurant.website.slice(0,4) === "http"
                                            ?             restaurant.website
                                            : "http://" + restaurant.website)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

    }

    Separator {
        width: column.width
        horizontalAlignment: Qt.AlignCenter
        color: Theme.secondaryHighlightColor
        height: 2
    }
}

