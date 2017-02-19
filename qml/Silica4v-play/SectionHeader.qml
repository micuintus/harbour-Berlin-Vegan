import VPlayApps 1.0
import BerlinVegan.components 1.0 as BVApp

AppText {

    property var title

    text: title

    anchors {
        right: parent.right

        rightMargin: BVApp.Theme.horizontalPageMargin
    }

}
