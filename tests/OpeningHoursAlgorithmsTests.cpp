
#include <tests/OpeningHoursAlgorithmsTests.h>
#include <src/OpeningHoursAlgorithms.h>

void OpeningHoursAlgorithms_TestIsPublicHoliday::test2018Holidays()
{
    // SETUP

    // see https://publicholidays.de/berlin/2018-dates/
    QDate newYearsDay       {2018, 01, 01};
    QDate goodFriday        {2018, 03, 30};
    QDate easterMonday      {2018, 04, 02};
    QDate labourDay         {2018, 05, 01};
    QDate ascensionDay      {2018, 05, 10};
    QDate whitMonday        {2018, 05, 21};
    QDate germanUnityDay    {2018, 10, 03};
    QDate christmasDay      {2018, 12, 25};
    QDate secondChristmasDay{2018, 12, 26};


    // EXECUTE AND VERIFY

    QVERIFY(isPublicHoliday(newYearsDay));
    QVERIFY(isPublicHoliday(goodFriday));
    QVERIFY(isPublicHoliday(easterMonday));
    QVERIFY(isPublicHoliday(labourDay));
    QVERIFY(isPublicHoliday(ascensionDay));
    QVERIFY(isPublicHoliday(whitMonday));
    QVERIFY(isPublicHoliday(germanUnityDay));
    QVERIFY(isPublicHoliday(christmasDay));
    QVERIFY(isPublicHoliday(secondChristmasDay));
}

void OpeningHoursAlgorithms_TestIsPublicHoliday::test2019Holidays()
{
    // SETUP

    // see https://publicholidays.de/berlin/2019-dates/
    QDate newYearsDay       {2019, 01, 01};
    QDate goodFriday        {2019, 04, 19};
    QDate easterMonday      {2019, 04, 22};
    QDate labourDay         {2019, 05, 01};
    QDate ascensionDay      {2019, 05, 30};
    QDate whitMonday        {2019, 06, 10};
    QDate germanUnityDay    {2019, 10, 03};
    QDate christmasDay      {2019, 12, 25};
    QDate secondChristmasDay{2019, 12, 26};


    // EXECUTE AND VERIFY

    QVERIFY(isPublicHoliday(newYearsDay));
    QVERIFY(isPublicHoliday(goodFriday));
    QVERIFY(isPublicHoliday(easterMonday));
    QVERIFY(isPublicHoliday(labourDay));
    QVERIFY(isPublicHoliday(ascensionDay));
    QVERIFY(isPublicHoliday(whitMonday));
    QVERIFY(isPublicHoliday(germanUnityDay));
    QVERIFY(isPublicHoliday(christmasDay));
    QVERIFY(isPublicHoliday(secondChristmasDay));
}

void OpeningHoursAlgorithms_TestIsPublicHoliday::test2020Holidays()
{
    // SETUP

    // see https://publicholidays.de/berlin/2019-dates/
    QDate newYearsDay       {2020, 01, 01};
    QDate goodFriday        {2020, 04, 10};
    QDate easterMonday      {2020, 04, 13};
    QDate labourDay         {2020, 05, 01};
    QDate ascensionDay      {2020, 05, 21};
    QDate whitMonday        {2020, 06, 01};
    QDate germanUnityDay    {2020, 10, 03};
    QDate christmasDay      {2020, 12, 25};
    QDate secondChristmasDay{2020, 12, 26};


    // EXECUTE AND VERIFY

    QVERIFY(isPublicHoliday(newYearsDay));
    QVERIFY(isPublicHoliday(goodFriday));
    QVERIFY(isPublicHoliday(easterMonday));
    QVERIFY(isPublicHoliday(labourDay));
    QVERIFY(isPublicHoliday(ascensionDay));
    QVERIFY(isPublicHoliday(whitMonday));
    QVERIFY(isPublicHoliday(germanUnityDay));
    QVERIFY(isPublicHoliday(christmasDay));
    QVERIFY(isPublicHoliday(secondChristmasDay));
}

void OpeningHoursAlgorithms_TestIsPublicHoliday::testRandomWorkDaySamples()
{
    // SETUP

    std::vector<QDate> workDays;

    workDays.push_back(QDate{2020, 01, 02});
    workDays.push_back(QDate{2019, 05, 02});
    workDays.push_back(QDate{2018, 06, 14});
    workDays.push_back(QDate{2018, 06, 15});
    workDays.push_back(QDate{2019, 05, 29});
    workDays.push_back(QDate{2018, 05, 22});
    workDays.push_back(QDate{2018, 10, 02});
    workDays.push_back(QDate{2019, 10, 02});
    workDays.push_back(QDate{2019, 10, 02});


    // EXECUTE and VERIFY

    for (auto const workDay : workDays)
    {
        QVERIFY(!isPublicHoliday(workDay));
    }
}

void OpeningHoursAlgorithms_TestIsShortAfterMidnight::before6oClockShouldReturnTrue()
{
    // SETUP

    std::vector<QDateTime> shortAfterMidnightDateTimes;

    shortAfterMidnightDateTimes.push_back(QDateTime{QDate{2017, 12, 01}, QTime{02, 20, 00}});
    shortAfterMidnightDateTimes.push_back(QDateTime{QDate{2022, 11, 01}, QTime{00, 00, 01}});
    shortAfterMidnightDateTimes.push_back(QDateTime{QDate{2018, 01, 01}, QTime{01, 00, 01}});


    // EXECUTE and VERIFY

    for (auto const dateTime : shortAfterMidnightDateTimes)
    {
        QVERIFY(isShortAfterMidnight(dateTime));
    }
}

void OpeningHoursAlgorithms_TestIsShortAfterMidnight::after6oClockShouldReturnFalse()
{
    // SETUP

    std::vector<QDateTime> notShortAfterMidnightDateTimes;

    notShortAfterMidnightDateTimes.push_back(QDateTime{QDate{2018, 02, 12}, QTime{23, 22, 49}});
    notShortAfterMidnightDateTimes.push_back(QDateTime{QDate{2019, 02, 23}, QTime{06, 00, 00}});


    // EXECUTE and VERIFY

    for (auto const dateTime : notShortAfterMidnightDateTimes)
    {
        QVERIFY(!isShortAfterMidnight(dateTime));
    }
}
