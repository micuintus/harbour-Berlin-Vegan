.pragma library

function defaultBooleanProperty(key)
{
    switch (key)
    {
        case 1:  return qsTr("yes");
        case 0:  return qsTr("no");
        default: return qsTr("unknown");
    }
}

function restaurantCategory(key)
{
    switch(key)
    {
        case 1:  return qsTr("omnivore");
        case 2:  return qsTr("omnivore \n(vegan declared)");
        case 3:  return qsTr("vegetarian");
        case 4:  return qsTr("vegetarian \n(vegan declared)");
        case 5:  return qsTr("100% vegan");
        default: return qsTr("unknown");
    }
}

function seatProperty(key)
{
    switch (key)
    {
        case -1: return qsTr("unknown");
        case  0: return qsTr("no");
        default: return key;
    }
}
