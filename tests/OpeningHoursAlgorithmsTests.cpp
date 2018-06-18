
#include <tests/OpeningHoursAlgorithmsTests.h>
#include <src/OpeningHoursAlgorithms.h>

void OpeningHoursAlgorithms_TestIsPublicHoliday::test2018Holidays()
{
    // SETUP

    // see https://publicholidays.de/berlin/2018-dates/
    const QDate newYearsDay       {2018, 01, 01};
    const QDate goodFriday        {2018, 03, 30};
    const QDate easterMonday      {2018, 04, 02};
    const QDate labourDay         {2018, 05, 01};
    const QDate ascensionDay      {2018, 05, 10};
    const QDate whitMonday        {2018, 05, 21};
    const QDate germanUnityDay    {2018, 10, 03};
    const QDate christmasDay      {2018, 12, 25};
    const QDate secondChristmasDay{2018, 12, 26};


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
    const QDate newYearsDay       {2019, 01, 01};
    const QDate goodFriday        {2019, 04, 19};
    const QDate easterMonday      {2019, 04, 22};
    const QDate labourDay         {2019, 05, 01};
    const QDate ascensionDay      {2019, 05, 30};
    const QDate whitMonday        {2019, 06, 10};
    const QDate germanUnityDay    {2019, 10, 03};
    const QDate christmasDay      {2019, 12, 25};
    const QDate secondChristmasDay{2019, 12, 26};


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
    const QDate newYearsDay       {2020, 01, 01};
    const QDate goodFriday        {2020, 04, 10};
    const QDate easterMonday      {2020, 04, 13};
    const QDate labourDay         {2020, 05, 01};
    const QDate ascensionDay      {2020, 05, 21};
    const QDate whitMonday        {2020, 06, 01};
    const QDate germanUnityDay    {2020, 10, 03};
    const QDate christmasDay      {2020, 12, 25};
    const QDate secondChristmasDay{2020, 12, 26};


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


void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::nonSundayHoldidayReturnsSundayIndex()
{
    // SETUP

    const QDate goodFriday2018        {2018, 03, 30};
    const QDate goodFriday2020        {2020, 04, 10};

    QTEST_ASSERT(goodFriday2018.dayOfWeek() != 7);
    QTEST_ASSERT(goodFriday2020.dayOfWeek() != 7);

    QTEST_ASSERT(isPublicHoliday(goodFriday2018));
    QTEST_ASSERT(isPublicHoliday(goodFriday2020));


    // EXECUTE

    const auto goodFriday2018Res = extractDayIndexAndMinute(QDateTime{goodFriday2018, QTime{13, 00, 00}});
    const auto goodFriday2020Res = extractDayIndexAndMinute(QDateTime{goodFriday2020, QTime{13, 00, 00}});


    // VERIFY

    QCOMPARE(SUNDAY_INDEX, goodFriday2018Res.first);
    QCOMPARE(SUNDAY_INDEX, goodFriday2020Res.first);
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::sundayHolidayAlsoRetunsSundayIndex()
{
    // SETUP

    const QDate firstXMasDay2016{2016, 12, 25};

    QTEST_ASSERT(firstXMasDay2016.dayOfWeek() == 7);
    QTEST_ASSERT(isPublicHoliday(firstXMasDay2016));


    // EXECUTE

    const auto res = extractDayIndexAndMinute(QDateTime{firstXMasDay2016, QTime{13, 00, 00}});


    // VERIFY

    QCOMPARE(SUNDAY_INDEX, res.first);
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::workDayReturnsDayIndex()
{
    // SETUP

    const QDate goodSaturday2018 {2018, 03, 31};
    const QDate goodSaturday2020 {2020, 04, 11};
    const QDate j2018_06_26      {2018, 06, 26};

    QTEST_ASSERT(goodSaturday2018.dayOfWeek() == 6);
    QTEST_ASSERT(goodSaturday2020.dayOfWeek() == 6);
    QTEST_ASSERT(j2018_06_26.dayOfWeek() == 2); // It's a Tuesday

    QTEST_ASSERT(!isPublicHoliday(goodSaturday2018));
    QTEST_ASSERT(!isPublicHoliday(goodSaturday2020));
    QTEST_ASSERT(!isPublicHoliday(j2018_06_26));


    // EXECUTE

    const auto goodSaturday2018Res = extractDayIndexAndMinute(QDateTime{goodSaturday2018, QTime{13, 00, 00}});
    const auto goodSaturday2020Res = extractDayIndexAndMinute(QDateTime{goodSaturday2020, QTime{13, 00, 00}});
    const auto j2018_06_26Res      = extractDayIndexAndMinute(QDateTime{j2018_06_26,      QTime{13, 00, 00}});


    // VERIFY

    QCOMPARE(static_cast<unsigned char>(SUNDAY_INDEX - 1), goodSaturday2018Res.first);
    QCOMPARE(static_cast<unsigned char>(SUNDAY_INDEX - 1), goodSaturday2020Res.first);
    QCOMPARE(static_cast<unsigned char>(SUNDAY_INDEX - 5), j2018_06_26Res.first); // It's a Tuesday
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::timeBefore6oClockReturnsDayIndexBefore()
{
    // SETUP

    const QDateTime j2018_06_26__5_30 { QDate{2018, 06, 26}, QTime{05, 30, 00} };
    QTEST_ASSERT(j2018_06_26__5_30.date().dayOfWeek() == 2); // It's a Tuesday


    // EXECUTE

    auto const res = extractDayIndexAndMinute(j2018_06_26__5_30);


    // VERIFY

    // Before 6 o Clock --> should return monday index
    QCOMPARE(static_cast<unsigned char>(SUNDAY_INDEX - 6), res.first);
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::timeAfter6oClockReturnsMinutes()
{
    // SETUP

    const QDateTime j2018_06_26__6_30 { QDate{2018, 06, 26}, QTime{06, 30, 00} };


    // EXECUTE

    auto const res = extractDayIndexAndMinute(j2018_06_26__6_30);


    // VERIFY

    //                            time: 06 : 30
    QCOMPARE(static_cast<unsigned>( 60 * 6 + 30), res.second);
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::timeBefore6oClockReturnsMinutesCountingFromDayBefore()
{
    // SETUP

    const QDateTime j2018_06_26__2_24 { QDate{2018, 06, 26}, QTime{02, 24, 00} };


    // EXECUTE

    auto const res = extractDayIndexAndMinute(j2018_06_26__2_24);


    // VERIFY

    //                              count from day before;      time: 02 : 24
    QCOMPARE(static_cast<unsigned>( 60 * 24                    +  60 * 2 + 24), res.second);
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::rightDayIndexReturnedIfShortAfterMidnightAndCurrentDayIsHoliday()
{
    // SETUP

    const QDate     goodFriday2018          {2018, 03, 30};
    const QDateTime goodFriday2018_2_o_clock{goodFriday2018, QTime{02, 00, 00}};

    QTEST_ASSERT(isPublicHoliday(goodFriday2018));
    QTEST_ASSERT(!isPublicHoliday(goodFriday2018.addDays(-1)));

    QTEST_ASSERT(isShortAfterMidnight(goodFriday2018_2_o_clock));


    // EXECUTE

    auto const res = extractDayIndexAndMinute(goodFriday2018_2_o_clock);


    // VERIFY
    //                                             Thursday
    QCOMPARE(res.first, static_cast<unsigned char>(SUNDAY_INDEX - 3));
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::rightDayIndexReturnedIfShortAfterMidnightAndDayBeforeIsHoliday()
{
    // SETUP

    const QDate     goodSaturday2018          {2018, 03, 31};
    const QDateTime goodSaturday2018_2_o_clock{goodSaturday2018, QTime{02, 00, 00}};

    QTEST_ASSERT(!isPublicHoliday(goodSaturday2018));
    QTEST_ASSERT(isPublicHoliday(goodSaturday2018.addDays(-1)));

    QTEST_ASSERT(isShortAfterMidnight(goodSaturday2018_2_o_clock));


    // EXECUTE

    auto const res = extractDayIndexAndMinute(goodSaturday2018_2_o_clock);


    // VERIFY           Good Friday is a holiday
    QCOMPARE(res.first, SUNDAY_INDEX);
}

void OpeningHoursAlgorithms_TestExtractDayIndexAndMinute::rightDayIndexReturnedIfShortAfterMidnightAndTodayAndDayBeforeAreHolidays()
{
    // SETUP

    const QDate     secondChristmasDay          {2018, 12, 26};
    const QDateTime secondChristmasDay_2_o_clock{secondChristmasDay, QTime{02, 30, 00}};

    QTEST_ASSERT(isPublicHoliday(secondChristmasDay));
    QTEST_ASSERT(isPublicHoliday(secondChristmasDay.addDays(-1)));

    QTEST_ASSERT(isShortAfterMidnight(secondChristmasDay_2_o_clock));


    // EXECUTE

    auto const res = extractDayIndexAndMinute(secondChristmasDay_2_o_clock);


    // VERIFY           1st xmas day is holiday
    QCOMPARE(res.first, SUNDAY_INDEX);
}
