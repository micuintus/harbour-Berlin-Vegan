import QtQuick 2.2
import Sailfish.Silica 1.0

ListModel
{
    property var restaurant;
    id: model

    Component.onCompleted: {
        /* NOTE: Unfortunately, we cannot go for static assignment here
                 --- ListElement { day: qsTr("Monday), hours: restautant.otMon }, ...,
                 because dynamic role values arent't supported in Qt 5.2;
                 see http://stackoverflow.com/questions/7659442/listelement-fields-as-properties */

        append({"day":qsTr("Monday"),    "hours": restaurant.otMon});
        append({"day":qsTr("Tuesday"),   "hours": restaurant.otTue});
        append({"day":qsTr("Wednesday"), "hours": restaurant.otWed});
        append({"day":qsTr("Thursday"),  "hours": restaurant.otThu});
        append({"day":qsTr("Friday"),    "hours": restaurant.otFri});
        append({"day":qsTr("Saturday"),  "hours": restaurant.otSat});
        append({"day":qsTr("Sunday"),    "hours": restaurant.otSun});
    }
}

