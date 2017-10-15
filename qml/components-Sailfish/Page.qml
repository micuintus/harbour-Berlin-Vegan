import Sailfish.Silica 1.0

Page {

    property string title
    signal pushed
    onPageContainerChanged: pushed()
}
