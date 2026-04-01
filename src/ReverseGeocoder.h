#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QPointer>
#include <QTimer>
#include <QJsonObject>
#include <QHash>
#include <QtQml/qqmlregistration.h>
#include "VenueModel.h"

// Background reverse geocoder that fills missing street addresses
// for OSM venues using the Nominatim API (1 req/sec rate limit).
// Results are cached persistently so geocoding only runs once per venue.
class ReverseGeocoder : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int pending READ pending NOTIFY pendingChanged)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)

public:
    explicit ReverseGeocoder(QObject *parent = nullptr);

    int pending() const { return m_queue.size(); }
    bool active() const { return m_active; }

    // Scan model for venues missing street, queue them for geocoding
    Q_INVOKABLE void enrichModel(VenueModel *model);

signals:
    void pendingChanged();
    void activeChanged();
    void venueEnriched(const QString& venueId, const QString& street);

protected:
    // Test-only constructor: accepts an externally-owned QNAM so unit tests
    // can inject a fake manager without touching the production singleton path.
    explicit ReverseGeocoder(QNetworkAccessManager& nam, QObject *parent = nullptr);

private:
    friend class TestReverseGeocoder;

    void processNext();
    void loadCache();
    void saveCache();
    QString cachePath() const;

    struct GeoRequest {
        QString venueId;
        double lat;
        double lon;
        int modelRow;
    };

    // In production: owns the manager. In tests: points to the injected one.
    QNetworkAccessManager* m_namPtr = nullptr;
    QNetworkAccessManager m_networkManagerOwned;
    QTimer m_rateTimer;
    QList<GeoRequest> m_queue;
    QHash<QString, QString> m_cache; // "lat,lon" → "street housenumber"
    QPointer<VenueModel> m_model;
    bool m_active = false;
    bool m_cacheLoaded = false;
    int m_processedCount = 0; // processed requests in current run (for periodic save)

    // Incremented each time enrichModel() starts a new geocoding run.
    // In-flight reply lambdas capture the generation at dispatch time and
    // skip the rate-timer restart if the generation has advanced, preventing
    // a stale reply from double-pumping the new run's queue.
    int m_generation = 0;
};
