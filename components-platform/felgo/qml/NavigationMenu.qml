import QtQuick
import Felgo
import BerlinVegan.components.platform 1.0 as BVApp

Navigation {
    navigationMode: Theme.isAndroid ? navigationModeDrawer : navigationModeTabs

    // On Android the Felgo drawer starts at y=0 (behind the transparent
    // status bar).  headerView content must be offset by the status bar /
    // safe area height so the skyline image starts right at the boundary
    // between the transparent system overlay and the opaque content area.
    // The navigation bar (action bar) overlaps the top of the image.
    readonly property real navigationBarOffset:
        BVApp.Platform.isAndroid
            ? (typeof nativeUtils !== "undefined"
               && nativeUtils.safeAreaInsets.top > Theme.statusBarHeight
                  ? nativeUtils.safeAreaInsets.top
                  : Theme.statusBarHeight)
            : 0
}
