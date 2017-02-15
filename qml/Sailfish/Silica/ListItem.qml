import VPlayApps 1.0

SimpleRow {

    signal clicked(int index)

    property var contentWidth
    property var contentHeight

    height: contentHeight

    // Do not show right angle in iOS
    style.showDisclosure: false

    // Own disclosure implementation, so that we can place it anywhere we want. By default the SimpleRow places it to
    // the very left, if no 'text' or 'detailText' is specified.
    /* TODO: place correctly or remove depending on row design.
    Icon {
        visible: Theme.isIos ? true : false
        icon: IconType.angleright
        color: "#c5c5ca"
        size: dp(22)
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: dp(16)
        }
    }
    */

}
