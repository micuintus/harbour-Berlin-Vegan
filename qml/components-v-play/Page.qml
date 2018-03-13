import VPlayApps 1.0

ListPage {
    id: page
    property alias pageStack: page.navigationStack

    signal activated

                 //% "Berlin-Vegan"
    title: qsTrId("id-berlin-vegan")
}
