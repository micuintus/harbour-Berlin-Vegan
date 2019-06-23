#pragma once

#include <QtTest/QTest>

class OpeningHoursAlgorithms_TestIsPublicHoliday : public QObject
{
    Q_OBJECT

private slots:

    void test2018Holidays();
    void test2019Holidays();
    void test2020Holidays();
    void testRandomWorkDaySamples();
};


class OpeningHoursAlgorithms_TestIsShortAfterMidnight : public QObject
{
    Q_OBJECT

private slots:

    void before6oClockShouldReturnTrue();
    void after6oClockShouldReturnFalse();
};


class OpeningHoursAlgorithms_TestExtractDayIndexAndMinute : public QObject
{
    Q_OBJECT

private slots:

    void nonSundayHoldidayReturnsSundayIndex();
    void sundayHolidayAlsoRetunsSundayIndex();

    void workDayReturnsDayIndex();

    void timeBefore6oClockReturnsDayIndexBefore();

    void timeAfter6oClockReturnsMinutes();
    void timeBefore6oClockReturnsMinutesCountingFromDayBefore();

    void rightDayIndexReturnedIfShortAfterMidnightAndCurrentDayIsHoliday();
    void rightDayIndexReturnedIfShortAfterMidnightAndDayBeforeIsHoliday();
    void rightDayIndexReturnedIfShortAfterMidnightAndTodayAndDayBeforeAreHolidays();
    void sundayIndexReturnedIfShortAfterMidnightAndCurrentDayIsMonday();

};

class OpeningHoursAlgorithms_TestCondenseOpeningHours : public QObject
{
    Q_OBJECT

private slots:

    void mondayToFridayTheSameCollapsesThem();
    void differentOpeningHoursInTheMiddleDontGetCondensed1();
    void differentOpeningHoursInTheMiddleDontGetCondensed2();
};
