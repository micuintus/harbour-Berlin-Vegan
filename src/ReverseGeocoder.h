#pragma once

#include <QObject>
#include <QNetworkAccessManager>
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

private:
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

    QNetworkAccessManager m_networkManager;
    QTimer m_rateTimer;
    QList<GeoRequest> m_queue;
    QHash<QString, QString> m_cache; // "lat,lon" → "street housenumber"
    VenueModel *m_model = nullptr;
    bool m_active = false;
    bool m_cacheLoaded = false;
};
