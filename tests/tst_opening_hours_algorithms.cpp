#include <QtTest>
#include "OpeningHoursAlgorithms.h"

class TestOpeningHoursAlgorithms : public QObject
{
    Q_OBJECT

private slots:
    void parseMinutes_simple()
    {
        auto r = parseOpeningMinutes("09:00 - 18:00");
        QCOMPARE(r["startMinute"].toInt(), 9 * 60);
        QCOMPARE(r["endMinute"].toInt(), 18 * 60);
    }

    void parseMinutes_midnight()
    {
        auto r = parseOpeningMinutes("18:00 - 02:00");
        QCOMPARE(r["startMinute"].toInt(), 18 * 60);
        QCOMPARE(r["endMinute"].toInt(), 26 * 60); // 24h + 2h
    }

    void parseMinutes_empty()
    {
        auto r = parseOpeningMinutes("");
        QCOMPARE(r["startMinute"].toInt(), 0);
        QCOMPARE(r["endMinute"].toInt(), 0);
    }

    void minuteFromTime_hourAndMinute()
    {
        QCOMPARE(minuteFromTimeString("09:30"), 9 * 60 + 30);
    }

    void minuteFromTime_hourOnly()
    {
        QCOMPARE(minuteFromTimeString("14"), 14 * 60);
    }

    void easterSunday_2024()
    {
        QCOMPARE(easterSunday(2024), QDate(2024, 3, 31));
    }

    void easterSunday_2025()
    {
        QCOMPARE(easterSunday(2025), QDate(2025, 4, 20));
    }

    void easterSunday_2026()
    {
        QCOMPARE(easterSunday(2026), QDate(2026, 4, 5));
    }

    void publicHoliday_newYear()
    {
        QVERIFY(isPublicHoliday(QDate(2026, 1, 1)));
    }

    void publicHoliday_berlinWomensDay()
    {
        QVERIFY(isPublicHoliday(QDate(2026, 3, 8)));
    }

    void publicHoliday_christmas()
    {
        QVERIFY(isPublicHoliday(QDate(2026, 12, 25)));
        QVERIFY(isPublicHoliday(QDate(2026, 12, 26)));
    }

    void publicHoliday_regularDay()
    {
        QVERIFY(!isPublicHoliday(QDate(2026, 3, 23)));
    }

    void isInRange_inside()
    {
        QVariantMap range{{"startMinute", 540}, {"endMinute", 1080}}; // 9:00-18:00
        QVERIFY(isInRange(range, 600));  // 10:00
        QVERIFY(isInRange(range, 540));  // 9:00 (start)
        QVERIFY(isInRange(range, 1080)); // 18:00 (end)
    }

    void isInRange_outside()
    {
        QVariantMap range{{"startMinute", 540}, {"endMinute", 1080}}; // 9:00-18:00
        QVERIFY(!isInRange(range, 480)); // 8:00
        QVERIFY(!isInRange(range, 1200)); // 20:00
    }

    void extractDayAndMinute_normalDay()
    {
        // Monday 14:30
        auto [dayIndex, minute] = extractDayIndexAndMinute(
            QDateTime(QDate(2026, 3, 23), QTime(14, 30)));
        QCOMPARE(dayIndex, MONDAY_INDEX);
        QCOMPARE(minute, (unsigned)(14 * 60 + 30));
    }

    void extractDayAndMinute_afterMidnight()
    {
        // Tuesday 02:00 should be treated as Monday late night
        auto [dayIndex, minute] = extractDayIndexAndMinute(
            QDateTime(QDate(2026, 3, 24), QTime(2, 0)));
        QCOMPARE(dayIndex, MONDAY_INDEX);
        QCOMPARE(minute, (unsigned)(26 * 60)); // 24h + 2h
    }
};

QTEST_MAIN(TestOpeningHoursAlgorithms)
#include "tst_opening_hours_algorithms.moc"
