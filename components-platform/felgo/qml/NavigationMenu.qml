import QtQuick
import Felgo
import BerlinVegan.components.platform 1.0 as BVApp

Navigation {
    navigationMode: Theme.isAndroid ? navigationModeDrawer : navigationModeTabs

    // On Android the drawer starts at y=0 of the NavigationStack, which means
    // its first row renders behind the NavigationBar.  drawerLogoHeight creates
    // a header-area spacer in the drawer that matches the (hotfix-adjusted)
    // NavigationBar height, pushing the menu items below it.
    // parent is the NavigationStack; parent.navigationBar is Felgo's bar.
    drawerLogoHeight: (BVApp.Platform.isAndroid && parent && parent.navigationBar)
                      ? parent.navigationBar.height
                      : 0
}
