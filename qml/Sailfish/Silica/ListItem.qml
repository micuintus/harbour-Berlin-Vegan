import VPlayApps 1.0

SimpleRow {

    signal clicked(int index)

    property var contentWidth

    text: namelabel.text
    detailText: "%1 %2".arg(streetLabel.text).arg(distance.text)

}
