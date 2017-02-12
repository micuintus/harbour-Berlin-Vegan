import VPlayApps 1.0

SimpleRow {

    signal clicked(int index)

    property var contentWidth
    property var contentHeight

    height: contentHeight

    // HACK: Display arrow on the bottom right
    text: " "
    detailText: " "

}
