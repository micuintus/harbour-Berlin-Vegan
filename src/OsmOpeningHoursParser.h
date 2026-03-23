#pragma once

#include <QString>
#include <QList>
#include <array>

// Parses OSM opening_hours format into per-day time strings
// compatible with the Berlin-Vegan otMon..otSun format.
// Handles ~90% of real-world values for Berlin gastro/shop venues.
class OsmOpeningHoursParser
{
public:
    struct Result {
        // Per-day time strings: "09:00 - 18:00" or "" (closed/unknown)
        // Index 0=Mon, 1=Tue, ..., 6=Sun
        std::array<QString, 7> days;
        bool parsed = false;
    };

    static Result parse(const QString& input);

private:
    static int dayIndex(QStringView day);
    static QList<int> expandDaySpec(const QString& spec);
    static QString normalizeTimeRange(const QString& timeRange);
};
