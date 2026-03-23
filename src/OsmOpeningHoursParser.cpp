#include "OsmOpeningHoursParser.h"
#include <QRegularExpression>

int OsmOpeningHoursParser::dayIndex(QStringView day)
{
    if (day == u"Mo") return 0;
    if (day == u"Tu") return 1;
    if (day == u"We") return 2;
    if (day == u"Th") return 3;
    if (day == u"Fr") return 4;
    if (day == u"Sa") return 5;
    if (day == u"Su") return 6;
    return -1;
}

QList<int> OsmOpeningHoursParser::expandDaySpec(const QString& spec)
{
    QList<int> result;

    const auto parts = spec.split(',');
    for (const auto& part : parts)
    {
        const auto trimmed = part.trimmed();
        if (trimmed.contains('-'))
        {
            const auto range = trimmed.split('-');
            if (range.size() == 2)
            {
                const int from = dayIndex(range[0].trimmed());
                const int to   = dayIndex(range[1].trimmed());
                if (from >= 0 && to >= 0)
                {
                    for (int i = from; ; i = (i + 1) % 7)
                    {
                        result.append(i);
                        if (i == to) break;
                    }
                }
            }
        }
        else
        {
            const int idx = dayIndex(trimmed);
            if (idx >= 0)
                result.append(idx);
        }
    }

    return result;
}

QString OsmOpeningHoursParser::normalizeTimeRange(const QString& timeRange)
{
    const auto intervals = timeRange.split(',');
    QStringList normalized;

    for (const auto& interval : intervals)
    {
        const auto parts = interval.trimmed().split('-');
        if (parts.size() == 2)
        {
            normalized.append(parts[0].trimmed() + " - " + parts[1].trimmed());
        }
        else
        {
            normalized.append(interval.trimmed());
        }
    }

    return normalized.join(", ");
}

OsmOpeningHoursParser::Result OsmOpeningHoursParser::parse(const QString& input)
{
    Result result;

    if (input.isEmpty())
        return result;

    if (input.trimmed() == "24/7")
    {
        result.parsed = true;
        for (auto& day : result.days)
            day = QStringLiteral("00:00 - 24:00");
        return result;
    }

    // Split on semicolons and commas-before-day-names
    // "Tu-Fr 12:00-22:00, Sa,Su 10:00-22:00" → ["Tu-Fr 12:00-22:00", "Sa,Su 10:00-22:00"]
    // But preserve commas within time ranges: "09:00-12:00,14:00-18:00"
    static const QRegularExpression ruleSplitRe(R"(\s*;\s*|\s*,\s*(?=(?:Mo|Tu|We|Th|Fr|Sa|Su)[\s,\-]))");
    const auto rules = input.split(ruleSplitRe);

    // Regex: optional day-spec, then time range(s)
    static const QRegularExpression ruleRe(
        R"(^\s*)"
        R"((?:((?:Mo|Tu|We|Th|Fr|Sa|Su)(?:\s*[-,]\s*(?:Mo|Tu|We|Th|Fr|Sa|Su))*)(?:\s*,\s*PH)?\s+)?)"
        R"((\d{1,2}:\d{2}\s*-\s*\d{1,2}:\d{2}(?:\s*,\s*\d{1,2}:\d{2}\s*-\s*\d{1,2}:\d{2})*))"
        R"(\s*$)"
    );

    bool anyParsed = false;

    for (const auto& rule : rules)
    {
        const auto trimmed = rule.trimmed();

        // Skip public holiday / school holiday rules
        if (trimmed.startsWith("PH") || trimmed.startsWith("SH"))
            continue;

        // Skip "off" rules (e.g., "Tu off")
        if (trimmed.endsWith("off"))
            continue;

        const auto match = ruleRe.match(trimmed);
        if (!match.hasMatch())
            continue;

        const auto daySpec = match.captured(1);
        const auto timeSpec = match.captured(2);
        const auto normalizedTime = normalizeTimeRange(timeSpec);

        QList<int> dayIndices;
        if (daySpec.isEmpty())
        {
            dayIndices = {0, 1, 2, 3, 4, 5, 6};
        }
        else
        {
            dayIndices = expandDaySpec(daySpec);
        }

        for (const int idx : dayIndices)
        {
            if (idx >= 0 && idx < 7)
            {
                result.days[idx] = normalizedTime;
                anyParsed = true;
            }
        }
    }

    result.parsed = anyParsed;
    return result;
}
