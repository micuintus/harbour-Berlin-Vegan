#include <QtTest>
#include "OSMProvider.h"

class TestOSMProvider : public QObject
{
    Q_OBJECT

private:
    OSMProvider m_provider;

    // Access the private method via the fact that osmElementToVenue returns
    // empty QJsonObject for filtered-out venues
    QJsonObject makeElement(const QString& name, double lat, double lon,
                            const QJsonObject& extraTags = {})
    {
        QJsonObject tags;
        tags["name"] = name;
        tags["diet:vegan"] = "yes";
        tags["opening_hours"] = "Mo-Fr 09:00-18:00";
        for (auto it = extraTags.begin(); it != extraTags.end(); ++it)
            tags[it.key()] = it.value();

        QJsonObject element;
        element["id"] = 12345;
        element["type"] = "node";
        element["lat"] = lat;
        element["lon"] = lon;
        element["tags"] = tags;
        return element;
    }

private slots:

    // --- Diet Category Mapping ---

    void veganOnly_mapsToVegan()
    {
        QCOMPARE(m_provider.mapDietTagToVegCategory("only", ""), 5);
    }

    void veganYes_mapsToOmnivorousVeganLabeled()
    {
        QCOMPARE(m_provider.mapDietTagToVegCategory("yes", ""), 2);
    }

    void vegetarianOnly_mapsToVegetarian()
    {
        QCOMPARE(m_provider.mapDietTagToVegCategory("", "only"), 3);
    }

    void vegetarianOnlyWithVeganYes_mapsToVegetarianVeganLabeled()
    {
        QCOMPARE(m_provider.mapDietTagToVegCategory("yes", "only"), 4);
    }

    void vegetarianYes_mapsToOmnivorousVeganLabeled()
    {
        QCOMPARE(m_provider.mapDietTagToVegCategory("", "yes"), 2);
    }

    void noTags_mapsToOmnivorous()
    {
        QCOMPARE(m_provider.mapDietTagToVegCategory("", ""), 1);
    }

    void veganOnly_overridesVegetarian()
    {
        // vegan=only should win regardless of vegetarian tag
        QCOMPARE(m_provider.mapDietTagToVegCategory("only", "yes"), 5);
        QCOMPARE(m_provider.mapDietTagToVegCategory("only", "only"), 5);
    }
};

QTEST_MAIN(TestOSMProvider)
#include "tst_osm_provider.moc"
