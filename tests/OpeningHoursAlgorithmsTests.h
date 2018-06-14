#pragma once

#include <QtTest/QTest>

class OpeningHoursAlgorithms_TestIsPublicHoliday : public QObject
{
    Q_OBJECT

private slots:

    void Test2018Holidays();
    void Test2019Holidays();
    void Test2020Holidays();
    void TestRandomWorkDaySamples();
};
