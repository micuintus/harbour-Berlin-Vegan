#pragma once

#include "VenueModel.h"

#include <QStandardItem>
#include <QVariant>
#include <QtQml/QJSValue>

// Condense opening hours part --->

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

// <--- Condense opening hours part

// Extract machine readable hours part --->

int getMinute(const QString time)
{
    if (time == NULL || time.isEmpty())
    {
        return 0;
    }

    auto hour = 0;
    auto minute = 0;
    if (time.contains(":"))
    {
        const auto parts = time.split(":");
        hour = parts[0].trimmed().toInt();
        minute = parts[1].trimmed().toInt();
    }
    else
    {
        hour = time.trimmed().toInt();
    }

    return hour * 60 + minute;
}

QVariantMap parseOpeningMinutes(const QString& openingString)
{
    unsigned startMinute = 0;
    unsigned endMinute = 0;
    if (openingString.contains("-"))
    {
        const auto parts = openingString.split("-");
        const auto startTime = parts[0];
        startMinute = getMinute(startTime);
        if (parts.size() > 1)
        {
            const auto endTime = parts[1];
            endMinute = getMinute(endTime);
            if (startMinute != 0 && endMinute == 0)
            {
                endMinute = 24 * 60;
            }
        }
        else if (startMinute != 0)
        {
            endMinute = 24 * 60;
        }
    }

    auto endMinutes = endMinute;
    if (endMinute < startMinute) // closing time is after midnight
    {
        endMinutes = endMinutes + 24 * 60;
    }

    return QVariantMap
    {
        { "startMinute", startMinute},
        { "endMinute",   endMinutes }
    };
}

QVariantList extractOpeningMinutes(const QVariantList& openingHours)
{
    QVariantList openingMinutes;
    std::transform(openingHours.begin(), openingHours.end(), std::back_inserter(openingMinutes),
                   [](const QVariant& openingLine)
    {
        const QString& openingString = openingLine.toMap()["hours"].toString();
        return parseOpeningMinutes(openingString);
    });

    return openingMinutes;
}


// <--- Extract machine readable hours part

void extractAndProcessOpenHoursData(QStandardItem& to, const QJSValue& from)
{
    auto const openingHours = extractOpenHoursData(from);
    auto const condensedOpeningHours = condenseOpeningHours(openingHours);

    to.setData(condensedOpeningHours, VenueModel::CondensedOpeningHours);

    auto const openingMinutes = extractOpeningMinutes(openingHours);
    to.setData(openingMinutes, VenueModel::OpeningMinutes);
}
