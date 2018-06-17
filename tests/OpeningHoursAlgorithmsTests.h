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
};
