#pragma once

#include "VenueModel.h"

#include <QStandardItem>
#include <QVariant>
#include <QtQml/QJSValue>


QVariantMap mergeElements(const QVariantList& openingHours, const unsigned from, const unsigned until)
{
    if (from == until)
    {
        return openingHours[from].toMap();
    }
    else
    {
        QVariantMap result;

        const auto& fromDay  = openingHours[from].toMap()["day"].toString();
        const auto& untilDay = openingHours[until].toMap()["day"].toString();

        result["day"]   =  fromDay + " - " + untilDay;
        result["hours"] = openingHours[from].toMap()["hours"];
        return result;
    }
}


QVariantList condenseOpeningHours(const QVariantList& uncondensedOpeningHours)
{
    QVariantList condensedOpeningHours;

    unsigned curr, next = 1;
    const unsigned numElements = uncondensedOpeningHours.size();

    while (curr < numElements)
    {
        next = curr + 1;

        while (next < numElements
               &&    uncondensedOpeningHours[curr].toMap()["hours"]
                  == uncondensedOpeningHours[next].toMap()["hours"])
        {
            next++;
        }

        condensedOpeningHours.append(mergeElements(uncondensedOpeningHours, curr, next - 1));

        curr = next;
    }

    return condensedOpeningHours;
}

QString hoursString(const QJSValue& from, const QString& property)
{
    QString hoursString = from.property(property).toVariant().toString();
    if (hoursString.isEmpty())
    {
                  //% "closed"
        return qtTrId("id-closed");
    }
    else
    {
        return hoursString;
    }
}


QVariantList extractOpenHoursData(const QJSValue& from)
{
    QVariantList uncondensedOpeningHours
    {
                                 //% "Monday"
        QVariantMap {{ "day", qtTrId("id-monday")},    { "hours", hoursString(from, "otMon") }},
                                //% "Tuesday"
        QVariantMap {{ "day", qtTrId("id-tuesday")},   { "hours", hoursString(from, "otTue") }},
                                 //% "Wednesday"
        QVariantMap {{ "day", qtTrId("id-wednesday")}, { "hours", hoursString(from, "otWed") }},
                                 //% "Thursday"
        QVariantMap {{ "day", qtTrId("id-thursday")},  { "hours", hoursString(from, "otThu") }},
                                 //% "Friday"
        QVariantMap {{ "day", qtTrId("id-friday")},    { "hours", hoursString(from, "otFri") }},
                                 //% "Saturday"
        QVariantMap {{ "day", qtTrId("id-saturday")},  { "hours", hoursString(from, "otSat") }},
                                 //% "Sunday"
        QVariantMap {{ "day", qtTrId("id-sunday")},    { "hours", hoursString(from, "otSun") }}
    };

    return uncondensedOpeningHours;
}

void extractAndProcessOpenHoursData(QStandardItem& to, const QJSValue& from)
{
    auto const openingHours = extractOpenHoursData(from);
    auto const condensedOpeningHours = condenseOpeningHours(openingHours);

    to.setData(condensedOpeningHours, VenueModel::CondensedOpeningHours);
}
