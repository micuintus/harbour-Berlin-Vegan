import QtQuick
import Felgo
import BerlinVegan.components.platform 1.0 as BVApp

Navigation {
    navigationMode: Theme.isAndroid ? navigationModeDrawer : navigationModeTabs
}
