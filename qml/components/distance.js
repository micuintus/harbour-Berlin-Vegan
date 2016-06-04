.pragma library

function humanReadableDistanceString(coordinate1, coordinate2)
{
    var distance = coordinate1.distanceTo(coordinate2);
    if (distance >= 1000)
    {
        var kilometres = Math.round(distance/100)/10;
        return kilometres.toString() + " km";
    }
    else
    {
        var metres = Math.round(distance);
        return metres.toString() + " m";
    }
}
