#include <QtTest>
#include "OsmOpeningHoursParser.h"

class TestOsmOpeningHours : public QObject
{
    Q_OBJECT

private slots:
    void empty()
    {
        auto r = OsmOpeningHoursParser::parse("");
        QVERIFY(!r.parsed);
    }

    void twentyFourSeven()
    {
        auto r = OsmOpeningHoursParser::parse("24/7");
        QVERIFY(r.parsed);
        for (int i = 0; i < 7; i++)
            QCOMPARE(r.days[i], "00:00 - 24:00");
    }

    void singleRange()
    {
        auto r = OsmOpeningHoursParser::parse("Mo-Fr 09:00-18:00");
        QVERIFY(r.parsed);
        QCOMPARE(r.days[0], "09:00 - 18:00"); // Mo
        QCOMPARE(r.days[4], "09:00 - 18:00"); // Fr
        QVERIFY(r.days[5].isEmpty()); // Sa
        QVERIFY(r.days[6].isEmpty()); // Su
    }

    void weekdayPlusWeekend()
    {
        auto r = OsmOpeningHoursParser::parse("Mo-Fr 09:00-18:00; Sa 10:00-14:00");
        QVERIFY(r.parsed);
        QCOMPARE(r.days[0], "09:00 - 18:00"); // Mo
        QCOMPARE(r.days[5], "10:00 - 14:00"); // Sa
        QVERIFY(r.days[6].isEmpty()); // Su
    }

    void noPrefix_allDays()
    {
        auto r = OsmOpeningHoursParser::parse("08:00-22:00");
        QVERIFY(r.parsed);
        for (int i = 0; i < 7; i++)
            QCOMPARE(r.days[i], "08:00 - 22:00");
    }

    void lunchBreak()
    {
        auto r = OsmOpeningHoursParser::parse("Mo-Fr 11:30-15:00,17:00-22:00");
        QVERIFY(r.parsed);
        QCOMPARE(r.days[0], "11:30 - 15:00, 17:00 - 22:00"); // Mo
        QCOMPARE(r.days[4], "11:30 - 15:00, 17:00 - 22:00"); // Fr
    }

    void commaSeparatedRules()
    {
        auto r = OsmOpeningHoursParser::parse("Tu-Fr 12:00-22:00, Sa,Su 10:00-22:00");
        QVERIFY(r.parsed);
        QVERIFY(r.days[0].isEmpty()); // Mo
        QCOMPARE(r.days[1], "12:00 - 22:00"); // Tu
        QCOMPARE(r.days[4], "12:00 - 22:00"); // Fr
        QCOMPARE(r.days[5], "10:00 - 22:00"); // Sa
        QCOMPARE(r.days[6], "10:00 - 22:00"); // Su
    }

    void publicHolidaySuffix()
    {
        auto r = OsmOpeningHoursParser::parse("Mo-Su,PH 09:00-05:00");
        QVERIFY(r.parsed);
        for (int i = 0; i < 7; i++)
            QCOMPARE(r.days[i], "09:00 - 05:00");
    }

    void singleDays()
    {
        auto r = OsmOpeningHoursParser::parse("Th 17:00-21:00; Fr 17:00-22:00; Sa 12:00-22:00; Su 12:00-20:00");
        QVERIFY(r.parsed);
        QVERIFY(r.days[0].isEmpty()); // Mo
        QVERIFY(r.days[1].isEmpty()); // Tu
        QVERIFY(r.days[2].isEmpty()); // We
        QCOMPARE(r.days[3], "17:00 - 21:00"); // Th
        QCOMPARE(r.days[4], "17:00 - 22:00"); // Fr
        QCOMPARE(r.days[5], "12:00 - 22:00"); // Sa
        QCOMPARE(r.days[6], "12:00 - 20:00"); // Su
    }

    void sixDayRange()
    {
        auto r = OsmOpeningHoursParser::parse("Mo-Sa 10:00-20:00");
        QVERIFY(r.parsed);
        for (int i = 0; i < 6; i++)
            QCOMPARE(r.days[i], "10:00 - 20:00");
        QVERIFY(r.days[6].isEmpty()); // Su closed
    }

    void commaListedDays()
    {
        auto r = OsmOpeningHoursParser::parse("Mo,We,Fr 09:00-18:00");
        QVERIFY(r.parsed);
        QCOMPARE(r.days[0], "09:00 - 18:00"); // Mo
        QVERIFY(r.days[1].isEmpty()); // Tu
        QCOMPARE(r.days[2], "09:00 - 18:00"); // We
        QVERIFY(r.days[3].isEmpty()); // Th
        QCOMPARE(r.days[4], "09:00 - 18:00"); // Fr
    }

    void unparseable()
    {
        auto r = OsmOpeningHoursParser::parse("by appointment");
        QVERIFY(!r.parsed);
    }

    void offRule()
    {
        auto r = OsmOpeningHoursParser::parse("Mo-Sa 10:00-20:00; Su off");
        QVERIFY(r.parsed);
        QCOMPARE(r.days[0], "10:00 - 20:00"); // Mo
        QVERIFY(r.days[6].isEmpty()); // Su = off
    }
};

QTEST_MAIN(TestOsmOpeningHours)
#include "tst_osm_opening_hours.moc"
