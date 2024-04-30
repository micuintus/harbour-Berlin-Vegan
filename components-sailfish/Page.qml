import Sailfish.Silica 1.0

Page {

    property string title
    signal pushed
    signal activated

    onPageContainerChanged: pushed()
    onStatusChanged: if (status === PageStatus.Active) activated()
}
