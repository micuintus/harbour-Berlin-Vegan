#include <QtTest>
#include <QJsonObject>
#include <QJsonArray>
#include <QStandardItem>
#include "VenueModel.h"

class TestDeduplication : public QObject
{
    Q_OBJECT

private:
    VenueModel m_model;

    void addBVVenue(const QString& name, double lat, double lon)
    {
        auto item = new QStandardItem;
        item->setData(name.toLower().replace(' ', '_'), VenueModel::VenueModelRoles::ID);
        item->setData(name, VenueModel::VenueModelRoles::Name);
        item->setData(simplifySearchString(name), VenueModel::VenueModelRoles::SimplifiedSearchName);
        item->setData(lat, VenueModel::VenueModelRoles::LatCoord);
        item->setData(lon, VenueModel::VenueModelRoles::LongCoord);
        item->setData(QStringLiteral("bv"), VenueModel::VenueModelRoles::DataSource);
        m_model.invisibleRootItem()->appendRow(item);
    }

    QJsonObject makeOSMVenue(const QString& name, double lat, double lon)
    {
        QJsonObject v;
        v["id"] = "osm_" + name.toLower().replace(' ', '_');
        v["name"] = name;
        v["latCoord"] = lat;
        v["longCoord"] = lon;
        return v;
    }

private slots:
    void init()
    {
        m_model.clear();
    }

    void sameLocationSameNameIsDuplicate()
    {
        addBVVenue("Kopps", 52.5300, 13.4000);
        QVERIFY(m_model.isDuplicate(makeOSMVenue("Kopps", 52.5300, 13.4000)));
    }

    void sameLocationDifferentNameIsDuplicate()
    {
        addBVVenue("Kopps Restaurant", 52.53000, 13.40000);
        QVERIFY(m_model.isDuplicate(makeOSMVenue("Completely Different", 52.53002, 13.40003)));
    }

    void nearbyWithSimilarNameIsDuplicate()
    {
        addBVVenue("Lucky Leek", 52.53000, 13.40000);
        QVERIFY(m_model.isDuplicate(makeOSMVenue("Lucky Leek Restaurant", 52.53100, 13.40100)));
    }

    void nearbyWithDifferentNameIsNotDuplicate()
    {
        addBVVenue("Kopps", 52.53000, 13.40000);
        QVERIFY(!m_model.isDuplicate(makeOSMVenue("Daluma", 52.53100, 13.40100)));
    }

    void farAwayIsNeverDuplicate()
    {
        addBVVenue("Kopps", 52.53000, 13.40000);
        QVERIFY(!m_model.isDuplicate(makeOSMVenue("Kopps", 52.55000, 13.42000)));
    }

    void prefixMatchWithinRange()
    {
        addBVVenue("Berlin Cigkofte", 52.53000, 13.40000);
        QVERIFY(m_model.isDuplicate(makeOSMVenue("Berlin Something", 52.53050, 13.40050)));
    }

    void firstWordMatchWithinRange()
    {
        addBVVenue("Sfizy Veg", 52.53000, 13.40000);
        QVERIFY(m_model.isDuplicate(makeOSMVenue("Sfizy", 52.53050, 13.40050)));
    }

    void emptyModelNeverDuplicate()
    {
        QVERIFY(!m_model.isDuplicate(makeOSMVenue("Anything", 52.53000, 13.40000)));
    }

    void osmVenueDeduplicatedAgainstOtherOSM()
    {
        // Add an OSM-sourced venue
        auto item = new QStandardItem;
        item->setData("osm_test", VenueModel::VenueModelRoles::ID);
        item->setData("Test Place", VenueModel::VenueModelRoles::Name);
        item->setData(simplifySearchString("Test Place"), VenueModel::VenueModelRoles::SimplifiedSearchName);
        item->setData(52.53000, VenueModel::VenueModelRoles::LatCoord);
        item->setData(13.40000, VenueModel::VenueModelRoles::LongCoord);
        item->setData(QStringLiteral("osm"), VenueModel::VenueModelRoles::DataSource);
        m_model.invisibleRootItem()->appendRow(item);

        // Same OSM venue (node+way duplicate) - SHOULD be detected
        QVERIFY(m_model.isDuplicate(makeOSMVenue("Test Place", 52.53000, 13.40000)));
    }
};

QTEST_MAIN(TestDeduplication)
#include "tst_deduplication.moc"
