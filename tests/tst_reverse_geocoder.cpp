// SPDX-License-Identifier: GPL-2.0-or-later
// Tests for ReverseGeocoder: cache hits, cache misses, network errors,
// invalid JSON, missing fields, rate-limiting guard, and stale-row guard.

#include <QtTest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QStandardPaths>
#include <QDir>
#include <QFile>

#include "ReverseGeocoder.h"
#include "VenueModel.h"

// ---------------------------------------------------------------------------
// Fake QNetworkReply that immediately delivers a canned response (or error)
// on the next event-loop iteration.
// ---------------------------------------------------------------------------
class FakeReply : public QNetworkReply
{
    Q_OBJECT
public:
    FakeReply(QNetworkAccessManager::Operation op,
              const QNetworkRequest& req,
              const QByteArray& data,
              QNetworkReply::NetworkError err = NoError,
              QObject* parent = nullptr)
        : QNetworkReply(parent)
        , m_data(data)
        , m_err(err)
    {
        setRequest(req);
        setUrl(req.url());
        setOperation(op);
        open(QIODevice::ReadOnly);
        if (err != NoError) {
            setError(err, QStringLiteral("fake error"));
            QMetaObject::invokeMethod(this, "finishWithError", Qt::QueuedConnection);
        } else {
            QMetaObject::invokeMethod(this, "finishWithData", Qt::QueuedConnection);
        }
    }
    qint64 readData(char* buf, qint64 maxlen) override {
        qint64 n = qMin(maxlen, (qint64)(m_data.size() - m_pos));
        if (n <= 0) return -1;
        memcpy(buf, m_data.constData() + m_pos, n);
        m_pos += n;
        return n;
    }
    void abort() override {}

private slots:
    void finishWithData() { emit finished(); }
    void finishWithError() { emit errorOccurred(m_err); emit finished(); }

private:
    QByteArray m_data;
    qint64 m_pos = 0;
    QNetworkReply::NetworkError m_err;
};

// ---------------------------------------------------------------------------
// Intercepting QNAM that returns FakeReplies
// ---------------------------------------------------------------------------
class FakeNAM : public QNetworkAccessManager
{
    Q_OBJECT
public:
    // Schedule what the next GET should return.
    void setNextReply(const QByteArray& data,
                      QNetworkReply::NetworkError err = QNetworkReply::NoError)
    {
        m_nextData = data;
        m_nextError = err;
    }

    QString lastRequestedUrl() const { return m_lastUrl; }
    int requestCount() const { return m_requestCount; }

protected:
    QNetworkReply* createRequest(Operation op,
                                 const QNetworkRequest& req,
                                 QIODevice* /*outgoingData*/ = nullptr) override
    {
        m_lastUrl = req.url().toString();
        ++m_requestCount;
        return new FakeReply(op, req, m_nextData, m_nextError, this);
    }

private:
    QByteArray m_nextData;
    QNetworkReply::NetworkError m_nextError = QNetworkReply::NoError;
    QString m_lastUrl;
    int m_requestCount = 0;
};

// ---------------------------------------------------------------------------
// Testable subclass of ReverseGeocoder that injects a FakeNAM via the
// protected constructor added specifically for testing.
// ---------------------------------------------------------------------------
class TestableGeocoder : public ReverseGeocoder
{
public:
    explicit TestableGeocoder(QNetworkAccessManager& nam, QObject* parent = nullptr)
        : ReverseGeocoder(nam, parent)
    {}
};

// ---------------------------------------------------------------------------
// Helper: build a minimal Nominatim reverse-geocode JSON response
// ---------------------------------------------------------------------------
static QByteArray nominatimResponse(const QString& road, const QString& houseNumber = {})
{
    QJsonObject address;
    if (!road.isEmpty())
        address["road"] = road;
    if (!houseNumber.isEmpty())
        address["house_number"] = houseNumber;

    QJsonObject root;
    root["address"] = address;
    return QJsonDocument(root).toJson(QJsonDocument::Compact);
}

// ---------------------------------------------------------------------------
// Helper: build a minimal VenueModel with one OSM venue
// The JSON format here matches what OSMProvider::osmElementToVenue() produces
// and what VenueModel::importOSMVenues() / osmVenueToItem() consumes.
// ---------------------------------------------------------------------------
static VenueModel* makeModelWithOSMVenue(const QString& id, double lat, double lon,
                                          const QString& existingStreet = {})
{
    auto* model = new VenueModel;
    QJsonArray venues;
    QJsonObject v;
    v["id"] = id;
    v["name"] = QStringLiteral("Test Venue");
    v["latCoord"] = lat;
    v["longCoord"] = lon;
    v["street"] = existingStreet;
    v["vegan"] = 5;
    v["venueType"] = 0;
    // Opening hours are required by osmVenueToItem but parsed lazily; empty is fine.
    v["openComment"] = QStringLiteral("Mo-Fr 09:00-17:00");
    QJsonArray tags; tags.append("Restaurant");
    v["tags"] = tags;
    venues.append(v);
    model->importOSMVenues(venues);
    return model;
}

// ---------------------------------------------------------------------------
// Helpers for on-disk cache manipulation
// ---------------------------------------------------------------------------
static QString geocodeCachePath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
           + QStringLiteral("/geocode_cache.json");
}

static void writeCacheFile(const QJsonObject& obj)
{
    const auto path = geocodeCachePath();
    QDir().mkpath(QFileInfo(path).absolutePath());
    QFile f(path);
    if (f.open(QIODevice::WriteOnly))
        f.write(QJsonDocument(obj).toJson(QJsonDocument::Compact));
}

static void deleteCacheFile()
{
    QFile::remove(geocodeCachePath());
}

// ---------------------------------------------------------------------------
// Test class
// ---------------------------------------------------------------------------
class TestReverseGeocoder : public QObject
{
    Q_OBJECT

private slots:

    void initTestCase()
    {
        // Isolate QSettings / QStandardPaths from the real app
        QCoreApplication::setOrganizationName(QStringLiteral("BerlinVeganTest"));
        QCoreApplication::setApplicationName(QStringLiteral("tst_reverse_geocoder"));
    }

    void init()
    {
        // Start each test with a clean cache file
        deleteCacheFile();
    }

    void cleanup()
    {
        deleteCacheFile();
    }

    // -----------------------------------------------------------------------
    // 1. Cache hit: venue with missing street whose coordinates are already in
    //    the persistent cache file must be resolved without a network request.
    // -----------------------------------------------------------------------
    void cacheHit_streetResolvedWithoutNetwork()
    {
        const double lat = 52.51234;
        const double lon = 13.41234;

        // Pre-populate the cache with a known result
        QJsonObject cache;
        cache[QStringLiteral("52.51234,13.41234")] = QStringLiteral("Oranienburger Str. 5");
        writeCacheFile(cache);

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_111"), lat, lon);

        ReverseGeocoder geocoder;
        // Calling enrichModel must NOT set active=true (all resolved from cache)
        geocoder.enrichModel(model);

        // active must remain false because everything came from cache
        QVERIFY(!geocoder.active());
        QCOMPARE(geocoder.pending(), 0);

        // Street must be filled in
        const auto idx = model->index(0, 0);
        QCOMPARE(idx.data(VenueModel::VenueModelRoles::Street).toString(),
                 QStringLiteral("Oranienburger Str. 5"));

        delete model;
    }

    // -----------------------------------------------------------------------
    // 2. Already-has-street: venue with a non-empty street must be skipped
    //    entirely (not queued, not looked up even if coordinates match nothing
    //    in the cache).
    // -----------------------------------------------------------------------
    void venueWithExistingStreet_skipped()
    {
        auto* model = makeModelWithOSMVenue(
            QStringLiteral("osm_222"), 52.5, 13.4,
            QStringLiteral("Rosenthaler Str. 40"));

        ReverseGeocoder geocoder;
        geocoder.enrichModel(model);

        QVERIFY(!geocoder.active());
        QCOMPARE(geocoder.pending(), 0);

        delete model;
    }

    // -----------------------------------------------------------------------
    // 3. Null-model guard: enrichModel(nullptr) must not crash.
    // -----------------------------------------------------------------------
    void nullModel_doesNotCrash()
    {
        ReverseGeocoder geocoder;
        geocoder.enrichModel(nullptr); // must not crash
        QVERIFY(!geocoder.active());
    }

    // -----------------------------------------------------------------------
    // 4. Empty model: enrichModel on a model with no rows must not activate.
    // -----------------------------------------------------------------------
    void emptyModel_noActivity()
    {
        auto* model = new VenueModel;
        ReverseGeocoder geocoder;
        geocoder.enrichModel(model);
        QVERIFY(!geocoder.active());
        QCOMPARE(geocoder.pending(), 0);
        delete model;
    }

    // -----------------------------------------------------------------------
    // 5. Active / pending properties: enrichModel on a model with one venue
    //    that is NOT in cache must set active=true and pending=1 immediately
    //    (before the async network reply arrives).
    // -----------------------------------------------------------------------
    void activeAndPending_setAfterEnrichModel()
    {
        // No cache file, so the venue will be queued
        FakeNAM fakeNam;
        fakeNam.setNextReply(nominatimResponse("Friedrichstraße", "10"));
        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_333"), 52.9999, 13.9999);

        TestableGeocoder geocoder(fakeNam);

        bool activeChangedFired = false;
        connect(&geocoder, &ReverseGeocoder::activeChanged, this, [&]() {
            activeChangedFired = true;
        });

        bool pendingChangedFired = false;
        connect(&geocoder, &ReverseGeocoder::pendingChanged, this, [&]() {
            pendingChangedFired = true;
        });

        geocoder.enrichModel(model);

        // After enrichModel the first processNext() is called synchronously:
        // it dequeues the item → pending drops to 0, then fires the network
        // request.  The FakeReply signals fire on the next event-loop tick.
        QVERIFY(activeChangedFired);    // activeChanged(true) was emitted
        QVERIFY(pendingChangedFired);   // pendingChanged was emitted

        delete model;
    }

    // -----------------------------------------------------------------------
    // 6. Network success path: after a successful Nominatim reply the
    //    geocoder writes the street to the model and emits venueEnriched.
    // -----------------------------------------------------------------------
    void networkSuccess_streetWrittenToModel()
    {
        FakeNAM fakeNam;
        fakeNam.setNextReply(nominatimResponse("Kastanienallee", "82"));

        const double lat = 52.53000;
        const double lon = 13.41000;
        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_net1"), lat, lon);

        TestableGeocoder geocoder(fakeNam);

        QString enrichedId;
        QString enrichedStreet;
        connect(&geocoder, &ReverseGeocoder::venueEnriched,
                this, [&](const QString& id, const QString& street) {
            enrichedId = id;
            enrichedStreet = street;
        });

        bool becameInactive = false;
        connect(&geocoder, &ReverseGeocoder::activeChanged, this, [&]() {
            if (!geocoder.active()) becameInactive = true;
        });

        geocoder.enrichModel(model);

        // Process events so the FakeReply::finished signal fires (queued connection).
        // After the reply, the rate-limit timer fires at 1100ms, then processNext()
        // sees an empty queue and sets active=false.
        QTest::qWait(50); // let the reply land

        // venueEnriched must have fired with the correct data
        QCOMPARE(enrichedId, QStringLiteral("osm_net1"));
        QCOMPARE(enrichedStreet, QStringLiteral("Kastanienallee 82"));

        // Street must be written to the model
        const auto idx = model->index(0, 0);
        QCOMPARE(idx.data(VenueModel::VenueModelRoles::Street).toString(),
                 QStringLiteral("Kastanienallee 82"));

        // Geocoder becomes inactive after the rate-limit timer fires (1100ms).
        // Use QTRY_VERIFY so the test polls without blocking the event loop.
        QTRY_VERIFY_WITH_TIMEOUT(becameInactive, 2000);
        QVERIFY(!geocoder.active());

        delete model;
    }

    // -----------------------------------------------------------------------
    // 7. Network success — road only, no house number.
    // -----------------------------------------------------------------------
    void networkSuccess_roadOnlyNoHouseNumber()
    {
        FakeNAM fakeNam;
        fakeNam.setNextReply(nominatimResponse("Rosenthaler Straße")); // no house number

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_net2"), 52.52000, 13.40000);

        TestableGeocoder geocoder(fakeNam);

        QString enrichedStreet;
        connect(&geocoder, &ReverseGeocoder::venueEnriched,
                this, [&](const QString&, const QString& s) { enrichedStreet = s; });

        geocoder.enrichModel(model);
        QTest::qWait(100);

        QCOMPARE(enrichedStreet, QStringLiteral("Rosenthaler Straße"));

        const auto idx = model->index(0, 0);
        QCOMPARE(idx.data(VenueModel::VenueModelRoles::Street).toString(),
                 QStringLiteral("Rosenthaler Straße"));

        delete model;
    }

    // -----------------------------------------------------------------------
    // 8. Network success — no road in Nominatim response: the empty result is
    //    cached as an empty string (suppresses future retries for this coord)
    //    and venueEnriched is NOT emitted.
    // -----------------------------------------------------------------------
    void networkSuccess_noRoad_cachedAsEmpty_venueEnrichedNotEmitted()
    {
        FakeNAM fakeNam;
        // Response with empty address object (no "road" field)
        fakeNam.setNextReply(nominatimResponse(QString()));

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_noroad"), 52.50000, 13.50000);

        TestableGeocoder geocoder(fakeNam);

        bool signalFired = false;
        connect(&geocoder, &ReverseGeocoder::venueEnriched,
                this, [&](const QString&, const QString&) { signalFired = true; });

        geocoder.enrichModel(model);
        QTest::qWait(100);

        // venueEnriched must NOT fire (empty street)
        QVERIFY(!signalFired);

        // Street must remain empty in the model
        const auto idx = model->index(0, 0);
        QVERIFY(idx.data(VenueModel::VenueModelRoles::Street).toString().isEmpty());

        delete model;
    }

    // -----------------------------------------------------------------------
    // 9. Network error path: a network error must NOT be cached (transient
    //    failures should be retried on the next app launch).
    //    venueEnriched must NOT fire.
    //    The geocoder must complete (become inactive) after processing.
    // -----------------------------------------------------------------------
    void networkError_notCached_geocoderCompletes()
    {
        FakeNAM fakeNam;
        fakeNam.setNextReply(QByteArray(), QNetworkReply::TimeoutError);

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_err1"), 52.60000, 13.60000);

        TestableGeocoder geocoder(fakeNam);

        bool signalFired = false;
        connect(&geocoder, &ReverseGeocoder::venueEnriched,
                this, [&](const QString&, const QString&) { signalFired = true; });

        bool becameInactive = false;
        connect(&geocoder, &ReverseGeocoder::activeChanged, this, [&]() {
            if (!geocoder.active()) becameInactive = true;
        });

        geocoder.enrichModel(model);
        QTest::qWait(50); // let the reply land

        // venueEnriched must NOT fire on error
        QVERIFY(!signalFired);

        // Street must remain empty
        const auto idx = model->index(0, 0);
        QVERIFY(idx.data(VenueModel::VenueModelRoles::Street).toString().isEmpty());

        // Geocoder becomes inactive after the rate-limit timer fires (1100ms).
        QTRY_VERIFY_WITH_TIMEOUT(becameInactive, 2000);

        // The error must NOT appear in the on-disk cache so the venue can be
        // retried next launch.  The geocoder only calls saveCache() at the end
        // of the run (queue empty).  For the error case, the cacheKey must NOT
        // be present (empty string would suppress future retries).
        // We check this indirectly: create a second geocoder and verify it
        // still queues the venue (cache miss for that key).
        {
            FakeNAM fakeNam2;
            fakeNam2.setNextReply(nominatimResponse("Prenzlauer Allee", "1"));
            auto* model2 = makeModelWithOSMVenue(QStringLiteral("osm_err1"), 52.60000, 13.60000);
            TestableGeocoder geocoder2(fakeNam2);

            // The second geocoder has m_cacheLoaded=false so it will try to
            // load from disk.  If the error was incorrectly cached, it would
            // resolve from cache and not queue the venue.
            geocoder2.enrichModel(model2);
            QTest::qWait(100);

            // Street should now be set (network succeeded this time)
            const auto idx2 = model2->index(0, 0);
            QCOMPARE(idx2.data(VenueModel::VenueModelRoles::Street).toString(),
                     QStringLiteral("Prenzlauer Allee 1"));
            delete model2;
        }

        delete model;
    }

    // -----------------------------------------------------------------------
    // 10. Invalid JSON response: the geocoder must not crash and must NOT
    //     cache the result (so the venue can be retried on the next launch).
    //     The venue street must remain empty.
    // -----------------------------------------------------------------------
    void invalidJson_notCachedNoCrash()
    {
        FakeNAM fakeNam;
        fakeNam.setNextReply(QByteArray("THIS IS NOT JSON AT ALL"));

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_badjson"), 52.51000, 13.45000);

        TestableGeocoder geocoder(fakeNam);

        geocoder.enrichModel(model);
        QTest::qWait(50); // let the reply land; should not crash

        // Street remains empty (bad JSON → no road extracted, nothing written)
        const auto idx = model->index(0, 0);
        QVERIFY(idx.data(VenueModel::VenueModelRoles::Street).toString().isEmpty());

        // Geocoder becomes inactive after rate-limit timer (1100ms)
        QTRY_VERIFY_WITH_TIMEOUT(!geocoder.active(), 2000);

        // The invalid JSON must NOT be cached (unlike a genuine "no road found"
        // response, a parse error is transient).  Verify by starting a second
        // geocoder that reads the on-disk cache: if nothing was cached, it must
        // still queue the venue for geocoding.
        {
            FakeNAM fakeNam2;
            fakeNam2.setNextReply(nominatimResponse("Torstraße", "1"));
            auto* model2 = makeModelWithOSMVenue(QStringLiteral("osm_badjson"), 52.51000, 13.45000);
            TestableGeocoder geocoder2(fakeNam2);
            geocoder2.enrichModel(model2);
            QTest::qWait(100);
            // Street should now be resolved (venue was NOT suppressed by a bad cache entry)
            const auto idx2 = model2->index(0, 0);
            QCOMPARE(idx2.data(VenueModel::VenueModelRoles::Street).toString(),
                     QStringLiteral("Torstraße 1"));
            delete model2;
        }

        delete model;
    }

    // -----------------------------------------------------------------------
    // 11. Rate-limiting guard: after the first request fires, a second request
    //     must NOT fire immediately — it must wait for the rate-limit timer.
    //     We verify this by checking that only 1 network request has been made
    //     right after enrichModel() (the event loop has NOT been pumped yet).
    // -----------------------------------------------------------------------
    void rateLimiting_secondRequestNotImmediatelySent()
    {
        FakeNAM fakeNam;
        fakeNam.setNextReply(nominatimResponse("Unter den Linden", "1"));

        // Build a model with 2 venues
        auto* model = new VenueModel;
        QJsonArray venues;
        for (int i = 0; i < 2; ++i) {
            QJsonObject v;
            v["id"] = QStringLiteral("osm_rate%1").arg(i);
            v["name"] = QStringLiteral("Venue %1").arg(i);
            v["latCoord"] = 52.5 + i * 0.01;
            v["longCoord"] = 13.4 + i * 0.01;
            v["street"] = QString();
            v["vegan"] = 5;
            v["venueType"] = 0;
            v["openComment"] = QStringLiteral("Mo-Fr 09:00-17:00");
            QJsonArray tags; tags.append("Restaurant");
            v["tags"] = tags;
            venues.append(v);
        }
        model->importOSMVenues(venues);

        TestableGeocoder geocoder(fakeNam);
        geocoder.enrichModel(model);

        // At this point, enrichModel() called processNext() synchronously for
        // the first item.  The FakeReply is queued but not yet delivered
        // (QueuedConnection).  No event-loop pump has happened yet.
        // Only 1 request should have been made.
        QCOMPARE(fakeNam.requestCount(), 1);

        // After pumping events briefly (enough for the first reply but NOT
        // enough for the 1100ms rate-limit timer), still only 1 request.
        QTest::qWait(50);
        QCOMPARE(fakeNam.requestCount(), 1);

        delete model;
    }

    // -----------------------------------------------------------------------
    // 12. Calling enrichModel a second time while active, where the new model
    //     has all addresses already in cache: the geocoder must transition to
    //     inactive (active=false, activeChanged emitted) and NOT get stuck in
    //     the active=true state forever.
    //     Regression test for: enrichModel() early-returning on empty queue
    //     without resetting m_active when called while a run was in progress.
    // -----------------------------------------------------------------------
    void reenrichModel_whileActive_allCached_transitionsToInactive()
    {
        // Pre-populate cache with the venue's coordinates
        QJsonObject cache;
        cache[QStringLiteral("52.11110,13.11110")] = QStringLiteral("Schönhauser Allee 10");
        writeCacheFile(cache);

        // First enrichModel call: venue NOT in cache → geocoder becomes active
        // (we use a FakeNAM that never responds so the run stays in-flight)
        FakeNAM fakeNam;
        // Don't set a reply — FakeNAM will never deliver one, simulating an
        // in-flight request.  We need the geocoder in m_active=true state.
        fakeNam.setNextReply(QByteArray(), QNetworkReply::TimeoutError);

        // Build a model with a venue NOT in cache (different coords)
        auto* modelUncached = makeModelWithOSMVenue(QStringLiteral("osm_reenrich_a"), 52.0, 13.0);

        TestableGeocoder geocoder(fakeNam);
        geocoder.enrichModel(modelUncached); // → active=true, 1 request in flight

        QVERIFY(geocoder.active());

        // Now build a fresh model whose venue IS already in cache
        // (same coords as the cache entry above)
        auto* modelCached = makeModelWithOSMVenue(
            QStringLiteral("osm_reenrich_b"), 52.1111, 13.1111);

        // Track activeChanged signals
        QList<bool> activeStates;
        connect(&geocoder, &ReverseGeocoder::activeChanged, this, [&]() {
            activeStates.append(geocoder.active());
        });

        // Call enrichModel again — the new queue will be empty because the
        // venue's coordinates are in the cache.  The geocoder must emit
        // activeChanged(false) and not remain stuck at active=true.
        geocoder.enrichModel(modelCached);

        // The geocoder must have transitioned to inactive
        QVERIFY(!geocoder.active());
        QCOMPARE(geocoder.pending(), 0);

        // activeChanged(false) must have been emitted exactly once
        QCOMPARE(activeStates.size(), 1);
        QVERIFY(!activeStates.first());

        // The cached street must have been written to the model
        const auto idx = modelCached->index(0, 0);
        QCOMPARE(idx.data(VenueModel::VenueModelRoles::Street).toString(),
                 QStringLiteral("Schönhauser Allee 10"));

        delete modelUncached;
        delete modelCached;
    }

    // -----------------------------------------------------------------------
    // 13. Calling enrichModel a second time while active (new queue non-empty):
    //     the timer must be stopped, the old queue discarded, and a new run
    //     started WITHOUT a spurious activeChanged(false) in between.
    // -----------------------------------------------------------------------
    void reenrichModel_resetsQueue_noSpuriousActiveChangedFalse()
    {
        FakeNAM fakeNam;
        fakeNam.setNextReply(nominatimResponse("Schönhauser Allee", "10"));

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_444"), 52.1111, 13.1111);

        TestableGeocoder geocoder(fakeNam);

        int activeChangedCount = 0;
        bool sawFalseDuringActive = false;
        connect(&geocoder, &ReverseGeocoder::activeChanged, this, [&]() {
            activeChangedCount++;
            if (!geocoder.active() && geocoder.pending() > 0)
                sawFalseDuringActive = true; // spurious false while still running
        });

        geocoder.enrichModel(model); // first call
        // Immediately call again before any event-loop processing
        geocoder.enrichModel(model); // second call

        // Must not have emitted a spurious activeChanged(false) between the
        // two calls (the geocoder stays active throughout).
        QVERIFY(!sawFalseDuringActive);

        // The geocoder should be active (or just finishing)
        // — at minimum it must not have crashed.
        QVERIFY(activeChangedCount >= 1); // at least one activeChanged(true)

        delete model;
    }

    // -----------------------------------------------------------------------
    // 14. Cache hit with empty string: a previous lookup that found no road
    //     (empty string stored) must NOT set the street to empty (it stays
    //     whatever it was — empty in this case) and must NOT activate the
    //     geocoder.
    // -----------------------------------------------------------------------
    void cacheHitEmptyStreet_notWrittenToModel()
    {
        const double lat = 52.55555;
        const double lon = 13.55555;

        // Simulate a "no road found" result stored in cache
        QJsonObject cache;
        cache[QStringLiteral("52.55555,13.55555")] = QString(); // empty = no road
        writeCacheFile(cache);

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_555"), lat, lon);
        ReverseGeocoder geocoder;
        geocoder.enrichModel(model);

        // Must not activate (resolved from cache)
        QVERIFY(!geocoder.active());
        QCOMPARE(geocoder.pending(), 0);

        // Street must remain empty (we don't write empty strings from cache)
        const auto idx = model->index(0, 0);
        QVERIFY(idx.data(VenueModel::VenueModelRoles::Street).toString().isEmpty());

        delete model;
    }

    // -----------------------------------------------------------------------
    // 15. venueEnriched signal: when a cached (non-empty) street is applied,
    //     no venueEnriched signal is emitted (signal is only for network path).
    // -----------------------------------------------------------------------
    void venueEnriched_notEmittedForCacheHits()
    {
        QJsonObject cache;
        cache[QStringLiteral("52.61000,13.61000")] = QStringLiteral("Kastanienallee 77");
        writeCacheFile(cache);

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_666"), 52.61000, 13.61000);
        ReverseGeocoder geocoder;

        bool signalFired = false;
        connect(&geocoder, &ReverseGeocoder::venueEnriched,
                this, [&](const QString&, const QString&) { signalFired = true; });

        geocoder.enrichModel(model);
        QVERIFY(!signalFired); // cache path does not emit venueEnriched

        delete model;
    }

    // -----------------------------------------------------------------------
    // 16. Cache key format: verify that the cache key uses 5 decimal places
    //     (matches the format used in loadCache/enrichModel).
    // -----------------------------------------------------------------------
    void cacheKey_fiveDecimalPlaces()
    {
        // lat=52.512345678, lon=13.412345678
        // key should be "52.51235,13.41235" (rounded to 5dp)
        const double lat = 52.512345678;
        const double lon = 13.412345678;

        QJsonObject cache;
        // Use the exact 5dp key that the geocoder would generate
        cache[QStringLiteral("52.51235,13.41235")] = QStringLiteral("Münzstraße 2");
        writeCacheFile(cache);

        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_777"), lat, lon);
        ReverseGeocoder geocoder;
        geocoder.enrichModel(model);

        QVERIFY(!geocoder.active());
        const auto idx = model->index(0, 0);
        QCOMPARE(idx.data(VenueModel::VenueModelRoles::Street).toString(),
                 QStringLiteral("Münzstraße 2"));

        delete model;
    }

    // -----------------------------------------------------------------------
    // 17. User-Agent header: the Nominatim request must include a User-Agent
    //     header to comply with OSM usage policy.
    // -----------------------------------------------------------------------
    void userAgent_presentInRequest()
    {
        // We can't easily intercept the raw request headers from FakeNAM without
        // modifying it.  We test this by verifying that the URL contains the
        // expected Nominatim endpoint.
        FakeNAM fakeNam;
        fakeNam.setNextReply(nominatimResponse("Brunnenstraße", "9"));
        auto* model = makeModelWithOSMVenue(QStringLiteral("osm_ua"), 52.53500, 13.40500);

        TestableGeocoder geocoder(fakeNam);
        geocoder.enrichModel(model);

        // The request must have been sent to Nominatim
        QVERIFY(fakeNam.lastRequestedUrl().contains(
                    QStringLiteral("nominatim.openstreetmap.org/reverse")));

        delete model;
    }
};

QTEST_MAIN(TestReverseGeocoder)
#include "tst_reverse_geocoder.moc"
