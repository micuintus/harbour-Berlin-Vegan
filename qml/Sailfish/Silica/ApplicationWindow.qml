import VPlayApps 1.0

App {

    property var initialPage
    property var cover

    NavigationStack {
        id: navigationStack
        initialPage: app.initialPage
    }

}
