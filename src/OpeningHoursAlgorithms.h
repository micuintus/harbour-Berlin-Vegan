#pragma once

#include <QVariant>
#include <QtQml/QJSValue>
#include <QDateTime>
#include <QtMath>

class QStandardItem;

constexpr int DAYS_PER_WEEK = 7;
constexpr int HOURS_PER_DAY = 24;
constexpr int MILLISECONDS_PER_SECOND = 1000;
constexpr int SECONDS_PER_MINUTE = 60;
constexpr int MINUTES_PER_HOUR = 60;
constexpr int MINUTES_PER_DAY = HOURS_PER_DAY * MINUTES_PER_HOUR;
constexpr int MINUTES_CLOSES_SOON = 30;

constexpr unsigned char MONDAY_INDEX    = 0;
constexpr unsigned char TUESDAY_INDEX   = 1;
constexpr unsigned char WEDNESDAY_INDEX = 2;
constexpr unsigned char THURSDAY_INDEX  = 3;
constexpr unsigned char FRIDAY_INDEX    = 4;
constexpr unsigned char SATURDAY_INDEX  = 5;
constexpr unsigned char SUNDAY_INDEX    = 6;

// Condense opening hours for display (merge consecutive days with same hours)
QVariantMap mergeElements(const QVariantList& openingHours, int from, int until, int todayIndex);
QVariantList condenseOpeningHours(const QVariantList& uncondensedOpeningHours, int todayIndex = -1);

// Extract opening hours from JSON venue data
QString hoursString(const QJSValue& from, const QString& property);
QVariantList extractOpenHoursData(const QJSValue& from);

// Parse time strings into minute-of-day values
int minuteFromTimeString(const QString& time);
QVariantMap parseOpeningMinutes(const QString& openingString);
QVariantList extractOpeningMinutes(const QVariantList& openingHours);

// Opening state calculations
inline bool isShortAfterMidnight(const QDateTime& dateTime)
{
    return dateTime.time() < QTime(6, 0, 0);
}

QDate easterSunday(int year);
bool isPublicHoliday(const QDate& date);
std::pair<unsigned char, unsigned> extractDayIndexAndMinute(QDateTime dateTime);
bool isInRange(const QVariantMap& openingMinutes, unsigned currentMinute);

// Process and store opening hours data in a model item
void extractAndProcessOpenHoursData(QStandardItem& to, const QJSValue& from);
