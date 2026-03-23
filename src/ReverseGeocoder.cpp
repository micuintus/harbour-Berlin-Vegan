#include "ReverseGeocoder.h"
#include "VenueModel.h"

#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>

static constexpr int RATE_LIMIT_MS = 1100; // Nominatim: max 1 req/sec

ReverseGeocoder::ReverseGeocoder(QObject *parent)
    : QObject(parent)
{
    m_rateTimer.setSingleShot(true);
    m_rateTimer.setInterval(RATE_LIMIT_MS);
    connect(&m_rateTimer, &QTimer::timeout, this, &ReverseGeocoder::processNext);
}

void ReverseGeocoder::enrichModel(VenueModel *model)
{
    if (!model || m_active) return;

    m_model = model;

    if (!m_cacheLoaded) {
        loadCache();
        m_cacheLoaded = true;
    }

    // Scan for venues missing street addresses
    m_queue.clear();
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
    netReq.setRawHeader("User-Agent", "BerlinVegan-App/3.7.0");
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
                const auto idx = m_model->index(req.modelRow, 0);
                if (idx.isValid()) {
                    m_model->setData(idx, street, VenueModel::VenueModelRoles::Street);
                    emit venueEnriched(req.venueId, street);
                }
            }
        }
        else
        {
            // Cache empty string so we don't retry failed lookups
            m_cache[cacheKey] = QString();
        }

        // Save cache periodically so progress isn't lost if app is killed
        if (m_cache.size() % 50 == 0)
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
