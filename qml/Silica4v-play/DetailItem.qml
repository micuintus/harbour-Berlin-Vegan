import VPlayApps 1.0
import BerlinVegan.components 1.0 as BVApp

AppText {

    property var label
    property var leftMargin
    property var rightMargin
    property var value

    text: label + " " + value

    anchors {
        left: parent.left

        leftMargin: BVApp.Theme.horizontalPageMargin
    }

}
