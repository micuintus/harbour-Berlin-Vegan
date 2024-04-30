import Sailfish.Silica 1.0 as Silica

Silica.TextSwitch {
    signal userToggled()
    onClicked: userToggled()
}
