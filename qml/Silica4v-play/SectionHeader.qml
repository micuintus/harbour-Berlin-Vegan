import VPlayApps 1.0
import BerlinVegan.components.platform 1.0 as BVApp

AppText {

    property var title

    text: title
    color: BVApp.Theme.primary

    anchors {
        right: parent.right

        margins: BVApp.Theme.paddingLarge
    }

}
