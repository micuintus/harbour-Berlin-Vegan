#pragma once

#include "VenueModel.h"

#include <QStandardItem>
#include <QVariant>
#include <QtQml/QJSValue>

#include <QDateTime>
#include <QtMath>


#define HOURS_PER_DAY 24
#define MINUTES_PER_HOUR 60
#define MINUTES_PER_DAY (HOURS_PER_DAY * MINUTES_PER_HOUR)


// Condense opening hours part --->

QVariantMap mergeElements(const QVariantList& openingHours,
                          const unsigned from,
                          const unsigned until)
{
    if (from == until)
    {
        return openingHours[from].toMap();
    }
    else
    {
        QVariantMap result;

        const auto& fromDay  = openingHours[from]. toMap()["day"].toString();
        const auto& untilDay = openingHours[until].toMap()["day"].toString();

        result["day"]   = fromDay + " - " + untilDay;
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
    const QString& hoursString = from.property(property).toVariant().toString();

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

unsigned minute(const QString& time)
{
    if (time == nullptr || time.isEmpty())
    {
        return 0;
    }

    unsigned hour   = 0;
    unsigned minute = 0;

    if (time.contains(":"))
    {
        const QStringList parts = time.split(":");
        hour   = parts[0].trimmed().toUInt();
        minute = parts[1].trimmed().toUInt();
    }
    else
    {
        hour = time.trimmed().toInt();
    }

    return hour * MINUTES_PER_HOUR + minute;
}

QVariantMap parseOpeningMinutes(const QString& openingString)
{
    unsigned startMinute = 0;
    unsigned endMinute   = 0;

    if (openingString.contains("-"))
    {
        const QStringList parts  = openingString.split("-");
        const QString& startTime = parts[0];

        startMinute = minute(startTime);

        if (parts.size() > 1)
        {
            const QString& endTime = parts[1];
            endMinute = minute(endTime);

            if (startMinute != 0 && endMinute == 0)
            {
                endMinute = MINUTES_PER_DAY;
            }
        }
        else if (startMinute != 0)
        {
            endMinute = MINUTES_PER_DAY;
        }
    }

    if (endMinute < startMinute) // closing time is after midnight
    {
        endMinute = endMinute + MINUTES_PER_DAY;
    }

    return QVariantMap
    {
        { "startMinute", startMinute },
        { "endMinute",   endMinute   }
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

// Opening state calculations --->

bool isAfterMidnight(const QDateTime& dateTime)
{
    const int currentHour = dateTime.time().hour();
    return currentHour >= 0 && currentHour <= 6;
}

bool isPublicHoliday(const QDateTime &dateTime)
{
    // calulate easter date
    // https://stackoverflow.com/a/1284335
    const auto Y = dateTime.date().year();
    const auto C = qFloor(Y/100);
    const auto N = Y - 19*qFloor(Y/19);
    const auto K = qFloor((C - 17)/25);
    auto I = C - qFloor(C/4) - qFloor((C - K)/3) + 19*N + 15;
    I = I - 30*qFloor((I/30));
    I = I - qFloor(I/28)*(1 - qFloor(I/28)*qFloor(29/(I + 1))*qFloor((21 - N)/11));
    auto J = Y + qFloor(Y/4) + I + 2 - C + qFloor(C/4);
    J = J - 7*qFloor(J/7);
    const auto L = I - J;
    const auto M = 3 + qFloor((L + 40)/44);
    const auto D = L + 28 - 31*qFloor(M/4);
    // easter sunday
    const QDate es(Y, M, D);

    // form https://publicholidays.de/berlin/2018-dates/
    // new year's eve
    const QDate ny(Y, 1, 1);
    // good friday
    const QDate gf(es.addDays(-2));
    // easter monday
    const QDate em(es.addDays(1));
    // labour day
    const QDate ld(es.addDays(30));
    // ascension day
    const QDate as(es.addDays(39));
    // whit monday
    const QDate wm(es.addDays(50));
    // day of german unity
    const QDate gu(Y, 10, 3);
    // christmas day
    const QDate cd(Y, 12, 25);
    // 2nd day of christmas
    const QDate dc(Y, 12, 26);

    // C++ doesn't allow for non-integral types in switch statements
    const auto date = dateTime.date();
    if (date == ny)
        return true;
    else if (date == gf)
        return true;
    else if (date == em)
        return true;
    else if (date == ld)
        return true;
    else if (date == as)
        return true;
    else if (date == wm)
        return true;
    else if (date == gu)
        return true;
    else if (date == cd)
        return true;
    else if (date == dc)
        return true;
    return false;
}

std::pair<int, unsigned> dayOfWeekAndCurrentMinute()
{
    const auto dateTime = QDateTime::currentDateTime();

    const unsigned currentHour = dateTime.time().hour();
    unsigned currentMinute = currentHour * MINUTES_PER_HOUR + dateTime.time().minute();

    const unsigned sundayIndex = 6;
    int dayOfWeek = dateTime.date().dayOfWeek() - 1; // Friday is 5, but we count from 0, so we need 4

    if (isAfterMidnight(dateTime))
    {
        currentMinute += MINUTES_PER_DAY; // add a complete day
        dayOfWeek--; // its short after midnight, so we use the opening hour from the day before

        if (dayOfWeek == -1)
        {
            dayOfWeek = sundayIndex; // sunday
        }
    }

    if (isPublicHoliday(dateTime)) // it is a holiday so take the opening hours from sunday
    {
        dayOfWeek = sundayIndex;
    }

    return { dayOfWeek, currentMinute };
}

bool isInRange(const QVariantMap& openingMinutes, const unsigned currentMinute)
{
    return currentMinute >= openingMinutes["startMinute"].toUInt()
        && currentMinute <= openingMinutes["endMinute"].toUInt();
}

// <--- Opening state calculations


void extractAndProcessOpenHoursData(QStandardItem& to, const QJSValue& from)
{
    auto const openingHours = extractOpenHoursData(from);
    auto const condensedOpeningHours = condenseOpeningHours(openingHours);

    to.setData(condensedOpeningHours, VenueModel::CondensedOpeningHours);

    auto const openingMinutes = extractOpeningMinutes(openingHours);
    to.setData(openingMinutes, VenueModel::OpeningMinutes);
}
