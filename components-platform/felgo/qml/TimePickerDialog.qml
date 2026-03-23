import Felgo
import BerlinVegan.components.platform 1.0 as BVApp
import QtQuick 2.5

Dialog {
  id: timePickerDialog
  contentHeight: dp(48) * 2.2
  outsideTouchable: true
                         //%  "Cancel"
  negativeActionLabel: qsTrId("id-timepicker-cancel")
            //% "Set Time"
  title: qsTrId("id-timepicker-set-time")
                          //% "OK"
  positiveActionLabel: qsTrId("id-timepicker-ok")
  onCanceled: { timePickerDialog.close(); time = initialTime }
  onAccepted: { timePickerDialog.close() }


  property date time
  property date initialTime
  onIsOpenChanged: {
    if(isOpen) {
      time = Qt.binding(function(){ return new Date(1982, 10, 02, pickerFrom.time.hour, pickerFrom.time.minute)})
      initialTime = time
    }
  }

  BVApp.TimePicker {
    id: pickerFrom
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 2 * dp(Theme.navigationBar.defaultBarItemPadding)
    height: parent.height
    fontFamily: Theme.normalFont.name
  }

  function openWith(time) {
    pickerFrom.setTime({hour: time.getHours(), minute: time.getMinutes()})
    open()
  }
}
