#include "ReverseGeocoder.h"
#include "VenueModel.h"

#include <QCoreApplication>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>

#ifndef APP_VERSION
#  define APP_VERSION "0.0.0"
#endif

static constexpr int RATE_LIMIT_MS = 1100; // Nominatim: max 1 req/sec
static constexpr int CACHE_SAVE_INTERVAL = 50; // Save after every N processed requests

ReverseGeocoder::ReverseGeocoder(QObject *parent)
    : QObject(parent)
{
    m_rateTimer.setSingleShot(true);
    m_rateTimer.setInterval(RATE_LIMIT_MS);
    connect(&m_rateTimer, &QTimer::timeout, this, &ReverseGeocoder::processNext);

    // Save partial progress if the app exits during geocoding.
    // Qt::UniqueConnection cannot deduplicate lambda slots, so we rely on the
    // fact that each ReverseGeocoder instance is constructed at most once
    // (enforced by QML_SINGLETON) to ensure this slot is connected exactly once.
    connect(QCoreApplication::instance(), &QCoreApplication::aboutToQuit,
            this, [this]() { if (!m_cache.isEmpty()) saveCache(); });
}

void ReverseGeocoder::enrichModel(VenueModel *model)
{
    if (!model) return;

    // If a geocoding run is already in progress (e.g. OSM data refreshed in the
    // background), stop the rate-limit timer so we don't fire processNext() with
    // a stale queue, then rebuild the queue from the updated model.
    if (m_active) {
        m_rateTimer.stop();
        m_active = false;
        emit activeChanged();
    }

    m_model = model;

    if (!m_cacheLoaded) {
        loadCache();
        m_cacheLoaded = true;
    }

    // Scan for venues missing street addresses
    m_queue.clear();
    m_processedCount = 0;
    int cachedHits = 0;

    for (int row = 0; row < model->rowCount(); ++row)
    {
        const auto idx = model->index(row, 0);
        const auto street = idx.data(VenueModel::VenueModelRoles::Street).toString();
        if (!street.isEmpty())
            continue;

        const auto source = idx.data(VenueModel::VenueModelRoles::DataSource).toString();
        if (source != "osm")
            continue;

        const double lat = idx.data(VenueModel::VenueModelRoles::LatCoord).toDouble();
        const double lon = idx.data(VenueModel::VenueModelRoles::LongCoord).toDouble();
        const auto id = idx.data(VenueModel::VenueModelRoles::ID).toString();

        // Check cache first
        const auto cacheKey = QStringLiteral("%1,%2")
            .arg(lat, 0, 'f', 5).arg(lon, 0, 'f', 5);

        if (m_cache.contains(cacheKey))
        {
            const auto& cachedStreet = m_cache[cacheKey];
            if (!cachedStreet.isEmpty()) {
                model->setData(idx, cachedStreet, VenueModel::VenueModelRoles::Street);
                cachedHits++;
            }
            continue;
        }

        m_queue.append({id, lat, lon, row});
    }

    if (cachedHits > 0)
        qInfo() << "Geocoder: resolved" << cachedHits << "addresses from cache";

    if (m_queue.isEmpty()) {
        qInfo() << "Geocoder: no venues need geocoding";
        return;
    }

    qInfo() << "Geocoder: queued" << m_queue.size() << "venues for reverse geocoding"
            << "(~" << m_queue.size() * RATE_LIMIT_MS / 1000 << "seconds)";

    m_active = true;
    emit activeChanged();
    emit pendingChanged();
    processNext();
}

void ReverseGeocoder::processNext()
{
    if (m_queue.isEmpty()) {
        m_active = false;
        emit activeChanged();
        saveCache();
        qInfo() << "Geocoder: finished, cache size:" << m_cache.size();
        return;
    }

    const auto req = m_queue.takeFirst();
    emit pendingChanged();

    const auto url = QStringLiteral(
        "https://nominatim.openstreetmap.org/reverse"
        "?format=jsonv2&lat=%1&lon=%2&zoom=18&addressdetails=1")
        .arg(req.lat, 0, 'f', 6).arg(req.lon, 0, 'f', 6);

    QNetworkRequest netReq(url);
    netReq.setRawHeader("User-Agent", "BerlinVegan-App/" APP_VERSION);
    netReq.setTransferTimeout(10000);

    auto *reply = m_networkManager.get(netReq);

    connect(reply, &QNetworkReply::finished, this, [this, reply, req]() {
        reply->deleteLater();

        const auto cacheKey = QStringLiteral("%1,%2")
            .arg(req.lat, 0, 'f', 5).arg(req.lon, 0, 'f', 5);

        if (reply->error() == QNetworkReply::NoError)
        {
            const auto doc = QJsonDocument::fromJson(reply->readAll());
            const auto address = doc.object()["address"].toObject();
            const auto road = address["road"].toString();
            const auto houseNumber = address["house_number"].toString();

            const auto street = road.isEmpty() ? QString()
                : road + (houseNumber.isEmpty() ? QString() : " " + houseNumber);

            m_cache[cacheKey] = street;

            if (!street.isEmpty() && m_model)
            {
                // Validate that the row still contains the same venue we queued.
                // If enrichModel() was called again mid-flight, row indices may
                // have shifted and we must not write to the wrong venue.
                const auto idx = m_model->index(req.modelRow, 0);
                if (idx.isValid()) {
                    const auto idAtRow = idx.data(VenueModel::VenueModelRoles::ID).toString();
                    if (idAtRow == req.venueId) {
                        m_model->setData(idx, street, VenueModel::VenueModelRoles::Street);
                        emit venueEnriched(req.venueId, street);
                    }
                }
            }
        }
        else
        {
            // Do NOT cache network errors: a transient failure (timeout, 429,
            // connection refused) must not permanently suppress future retries.
            // Only an explicit "no road found" result (road.isEmpty()) is cached
            // as an empty string above in the success branch.
            qWarning() << "Geocoder: network error for" << req.venueId
                       << ":" << reply->errorString();
        }

        // Save cache periodically so progress isn't lost if app is killed.
        // Use a dedicated counter rather than total cache size (which may
        // already be large from a previous run loaded from disk).
        ++m_processedCount;
        if (m_processedCount % CACHE_SAVE_INTERVAL == 0)
            saveCache();

        // Schedule next request after rate limit delay
        m_rateTimer.start();
    });
}

// --- Persistent cache ---

QString ReverseGeocoder::cachePath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
           + QStringLiteral("/geocode_cache.json");
}

void ReverseGeocoder::loadCache()
{
    QFile file(cachePath());
    if (!file.open(QIODevice::ReadOnly)) return;

    const auto doc = QJsonDocument::fromJson(file.readAll());
    if (!doc.isObject()) return;

    const auto obj = doc.object();
    for (auto it = obj.begin(); it != obj.end(); ++it)
        m_cache[it.key()] = it.value().toString();

    qInfo() << "Geocoder: loaded" << m_cache.size() << "cached addresses";
}

void ReverseGeocoder::saveCache()
{
    const auto path = cachePath();
    QDir().mkpath(QFileInfo(path).absolutePath());

    QJsonObject obj;
    for (auto it = m_cache.begin(); it != m_cache.end(); ++it)
        obj[it.key()] = it.value();

    QFile file(path);
    if (file.open(QIODevice::WriteOnly))
        file.write(QJsonDocument(obj).toJson(QJsonDocument::Compact));
}
