import QtQuick
import org.kde.kirigami as Kirigami

// Navigation stack wrapper for Kirigami.
// Exposes a Felgo-compatible API while using Kirigami's pageStack.
Item {
    id: root

    // The initial page component to load
    property var initialPage

    // Internal reference to the application window's pageStack
    readonly property var _pageStack: {
        var win = applicationWindow()
        return win ? win.pageStack : null
    }

    // Current depth of the stack
    readonly property int depth: _pageStack ? _pageStack.depth : 0

    // Whether split view is active (not supported on Kirigami, always false)
    property bool splitView: false
    readonly property bool splitViewActive: false

    // Push a page onto the stack
    function push(url, props) {
        if (!_pageStack) {
            console.warn("NavigationStack: pageStack not available")
            return null
        }
        return _pageStack.push(url, props || {})
    }

    // Push an "attached" page - on Kirigami this just does a regular push
    // On Felgo this adds a right bar item for split view
    function pushAttached(url, props, icon) {
        // Just do a regular push on Kirigami
        return push(url, props)
    }

    // Pop the current page
    function pop() {
        if (!_pageStack) {
            console.warn("NavigationStack: pageStack not available")
            return
        }
        _pageStack.pop()
    }

    // Pop all pages except the first
    function popAllExceptFirst() {
        if (!_pageStack) {
            console.warn("NavigationStack: pageStack not available")
            return
        }
        while (_pageStack.depth > 1) {
            _pageStack.pop()
        }
    }

    // Clear the stack and push a new initial page
    function clearAndPush(pageComponent) {
        if (!_pageStack) {
            console.warn("NavigationStack: pageStack not available")
            return null
        }
        _pageStack.clear()
        return _pageStack.push(pageComponent)
    }

    // Get a page at a specific index
    function getPage(index) {
        if (!_pageStack || index < 0 || index >= _pageStack.depth) {
            return null
        }
        return _pageStack.get(index)
    }

    // Compatibility: currentPage property
    readonly property var currentPage: _pageStack ? _pageStack.currentItem : null

    // Signal when navigation stack changes
    signal navigationStackChanged()

    // Watch the pageStack for changes
    Connections {
        target: _pageStack
        function onDepthChanged() { root.navigationStackChanged() }
        function onCurrentItemChanged() { root.navigationStackChanged() }
    }

    // Expose pageStack to child pages (compatibility with Felgo pattern)
    Component.onCompleted: {
        navigationStackChanged()
    }
}
