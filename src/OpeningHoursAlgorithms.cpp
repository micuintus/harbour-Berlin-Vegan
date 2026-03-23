#include "OpeningHoursAlgorithms.h"
#include "VenueModel.h"

#include <QStandardItem>
#include <QStringList>

QVariantMap mergeElements(const QVariantList& openingHours,
                          const int from,
                          const int until,
                          const int todayIndex)
{
    QVariantMap result;

    if (from == until)
    {
        result = openingHours[from].toMap();
    }
    else
    {
        const auto& fromDay  = openingHours[from]. toMap()["day"].toString();
        const auto& untilDay = openingHours[until].toMap()["day"].toString();

        result["day"]      = fromDay + " - " + untilDay;
        result["hours"]    = openingHours[from].toMap()["hours"];
    }

    result["current"]  = from <= todayIndex && todayIndex <= until;

    return result;
}

QVariantList condenseOpeningHours(const QVariantList& uncondensedOpeningHours, const int todayIndex)
{
    QVariantList condensedOpeningHours;

    int curr = 0;
    const int numElements = uncondensedOpeningHours.size();

    while (curr < numElements)
    {
        int next = curr + 1;

        while (next < numElements
               &&    uncondensedOpeningHours[curr].toMap()["hours"]
                  == uncondensedOpeningHours[next].toMap()["hours"]
               && uncondensedOpeningHours[next].toMap()["day"]
                  != qtTrId("id-sunday")) // Do not merge sundays
        {
            next++;
        }

        condensedOpeningHours.append(mergeElements(uncondensedOpeningHours, curr, next - 1, todayIndex));

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
                                 //% "Sunday / Holiday"
        QVariantMap {{ "day", qtTrId("id-sunday")},    { "hours", hoursString(from, "otSun") }}
    };

    return uncondensedOpeningHours;
}

int minuteFromTimeString(const QString& time)
{
    if (time.isNull() || time.isEmpty())
    {
        return 0;
    }

    int hour   = 0;
    int minute = 0;

    if (time.contains(":"))
    {
        const QStringList parts = time.split(":");
        hour   = parts[0].trimmed().toInt();
        minute = parts[1].trimmed().toInt();
    }
    else
    {
        hour = time.trimmed().toInt();
    }

    return hour * MINUTES_PER_HOUR + minute;
}

QVariantMap parseOpeningMinutes(const QString& openingString)
{
    int startMinute = 0;
    int endMinute   = 0;

    if (openingString.contains("-"))
    {
        const QStringList parts  = openingString.split("-");
        const QString& startTime = parts[0];

        startMinute = minuteFromTimeString(startTime);

        if (parts.size() > 1)
        {
            const QString& endTime = parts[1];
            endMinute = minuteFromTimeString(endTime);

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
        endMinute += MINUTES_PER_DAY;
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

QDate easterSunday(int year)
{
    // calculate easter date
    // https://stackoverflow.com/a/1284335
    const auto C = qFloor(year/100);
    const auto N = year - 19*qFloor(year/19);
    const auto K = qFloor((C - 17)/25);
    auto I = C - qFloor(C/4) - qFloor((C - K)/3) + 19*N + 15;
    I = I - 30*qFloor((I/30));
    I = I - qFloor(I/28)*(1 - qFloor(I/28)*qFloor(29/(I + 1))*qFloor((21 - N)/11));
    auto J = year + qFloor(year/4) + I + 2 - C + qFloor(C/4);
    J = J - 7*qFloor(J/7);
    const auto L = I - J;
    const auto month = 3 + qFloor((L + 40)/44);
    const auto day = L + 28 - 31*qFloor(month/4);

    return QDate{year, month, day};
}

bool isPublicHoliday(const QDate &date)
{
    const auto year = date.year();
    auto const es = easterSunday(year);

    const QDate newYearsDay(year, 1, 1);
    const QDate internationalWomensDay(year, 3, 8);
    const QDate goodFriday(es.addDays(-2));
    const QDate easterMonday(es.addDays(1));
    const QDate labourDay{year, 05, 01};
    const QDate ascensionDay(es.addDays(39));
    const QDate whitMonday(es.addDays(50));
    const QDate dayOfGermanUnity(year, 10, 3);
    const QDate firstChristmasDay(year, 12, 25);
    const QDate secondChristmasDay(year, 12, 26);

    return date == newYearsDay
        || date == internationalWomensDay
        || date == goodFriday
        || date == easterMonday
        || date == labourDay
        || date == ascensionDay
        || date == whitMonday
        || date == dayOfGermanUnity
        || date == firstChristmasDay
        || date == secondChristmasDay;
}

std::pair<unsigned char, unsigned> extractDayIndexAndMinute(QDateTime dateTime)
{
    const int currentHour = dateTime.time().hour();
    int currentMinute = currentHour * MINUTES_PER_HOUR + dateTime.time().minute();

    unsigned char dayIndex = static_cast<unsigned char>(dateTime.date().dayOfWeek() - 1);

    if (isShortAfterMidnight(dateTime))
    {
        currentMinute += MINUTES_PER_DAY;
        dayIndex = (dayIndex + 6) % DAYS_PER_WEEK;
        dateTime = dateTime.addDays(-1);
    }

    if (isPublicHoliday(dateTime.date()))
    {
        dayIndex = SUNDAY_INDEX;
    }

    return { dayIndex, currentMinute };
}

bool isInRange(const QVariantMap& openingMinutes, const unsigned currentMinute)
{
    return currentMinute >= openingMinutes["startMinute"].toUInt()
        && currentMinute <= openingMinutes["endMinute"].toUInt();
}

void extractAndProcessOpenHoursData(QStandardItem& to, const QJSValue& from)
{
    auto const openingHours = extractOpenHoursData(from);
    to.setData(openingHours, VenueModel::OpeningHours);

    auto const openingMinutes = extractOpeningMinutes(openingHours);
    to.setData(openingMinutes, VenueModel::OpeningMinutes);
}
