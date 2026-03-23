#include <QtTest>
#include <QCoreApplication>
#include "FavoritesManager.h"

class TestFavorites : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
        // Use a dedicated test namespace so QSettings never touches real app data
        QCoreApplication::setOrganizationName(QStringLiteral("BerlinVeganTest"));
        QCoreApplication::setApplicationName(QStringLiteral("tst_favorites"));
    }

    void init()
    {
        // Clean state for each test
        FavoritesManager mgr;
        for (const auto& id : mgr.getFavoriteIds())
            mgr.removeFavorite(id);
    }

    void emptyByDefault()
    {
        FavoritesManager mgr;
        QVERIFY(mgr.getFavoriteIds().isEmpty());
    }

    void addAndRetrieve()
    {
        FavoritesManager mgr;
        mgr.addFavorite("venue_1");
        mgr.addFavorite("venue_2");

        auto ids = mgr.getFavoriteIds();
        QCOMPARE(ids.size(), 2);
        QVERIFY(ids.contains("venue_1"));
        QVERIFY(ids.contains("venue_2"));
    }

    void addDuplicate_ignored()
    {
        FavoritesManager mgr;
        mgr.addFavorite("venue_1");
        mgr.addFavorite("venue_1");
        QCOMPARE(mgr.getFavoriteIds().size(), 1);
    }

    void removeExisting()
    {
        FavoritesManager mgr;
        mgr.addFavorite("venue_1");
        mgr.addFavorite("venue_2");
        mgr.removeFavorite("venue_1");

        auto ids = mgr.getFavoriteIds();
        QCOMPARE(ids.size(), 1);
        QVERIFY(!ids.contains("venue_1"));
        QVERIFY(ids.contains("venue_2"));
    }

    void removeNonExisting_noEffect()
    {
        FavoritesManager mgr;
        mgr.addFavorite("venue_1");
        mgr.removeFavorite("nonexistent");
        QCOMPARE(mgr.getFavoriteIds().size(), 1);
    }

    void isFavorite()
    {
        FavoritesManager mgr;
        mgr.addFavorite("venue_1");
        QVERIFY(mgr.isFavorite("venue_1"));
        QVERIFY(!mgr.isFavorite("venue_2"));
    }

    void persistsAcrossInstances()
    {
        {
            FavoritesManager mgr;
            mgr.addFavorite("persistent_venue");
        }
        // New instance should load from QSettings
        FavoritesManager mgr2;
        QVERIFY(mgr2.isFavorite("persistent_venue"));
        // Clean up
        mgr2.removeFavorite("persistent_venue");
    }
};

QTEST_MAIN(TestFavorites)
#include "tst_favorites.moc"
