#include "VenueDataLoader.h"

#include <QNetworkReply>
#include <QFile>
#include <QStandardPaths>
#include <QDir>
#include <QTimer>

static const QUrl GASTRO_URL{QStringLiteral("https://www.berlin-vegan.de/app/data/GastroLocations.json")};
static const QUrl SHOPPING_URL{QStringLiteral("https://data.berlin-vegan.de/api/ShoppingLocations.json")};
static const QString GASTRO_FILENAME = QStringLiteral("GastroLocations.json");
static const QString SHOPPING_FILENAME = QStringLiteral("ShoppingLocations.json");
static constexpr int NETWORK_TIMEOUT_MS = 15000;

VenueDataLoader::VenueDataLoader(QObject *parent)
    : QObject(parent)
{
}

void VenueDataLoader::loadGastroVenues()
{
    fetchFromNetwork(GASTRO_URL, true);
}

void VenueDataLoader::loadShoppingVenues()
{
    fetchFromNetwork(SHOPPING_URL, false);
}

void VenueDataLoader::fetchFromNetwork(const QUrl& url, bool isGastro)
{
    m_pendingRequests++;
    emit loadingChanged();

    auto* reply = m_networkManager.get(QNetworkRequest(url));
    const QString filename = isGastro ? GASTRO_FILENAME : SHOPPING_FILENAME;

    // Timeout: fall back to cache after NETWORK_TIMEOUT_MS
    auto* timer = new QTimer(reply);
    timer->setSingleShot(true);
    timer->start(NETWORK_TIMEOUT_MS);

    QObject::connect(timer, &QTimer::timeout, reply, [this, reply, filename, isGastro]() {
        reply->abort();
        qInfo() << "Network timeout for" << filename << "- trying cache";
        loadFromCache(filename, isGastro);
    });

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, filename, isGastro, timer]() {
        timer->stop();
        reply->deleteLater();

        if (reply->error() == QNetworkReply::NoError)
        {
            const QString json = QString::fromUtf8(reply->readAll());
            saveToCache(filename, json);
            qInfo() << "Successfully downloaded" << filename;

            if (isGastro)
                emit gastroDataReady(json);
            else
                emit shoppingDataReady(json);
        }
        else if (reply->error() != QNetworkReply::OperationCanceledError)
        {
            // Not a timeout cancel - actual error, try cache
            qWarning() << "Network error for" << filename << ":" << reply->errorString();
            loadFromCache(filename, isGastro);
        }
        // OperationCanceledError is handled by the timeout handler

        m_pendingRequests--;
        emit loadingChanged();
    });
}

void VenueDataLoader::loadFromCache(const QString& filename, bool isGastro)
{
    const QString path = cacheFilePath(filename);
    QFile file(path);

    if (file.open(QIODevice::ReadOnly))
    {
        const QString json = QString::fromUtf8(file.readAll());
        qInfo() << "Loaded" << filename << "from cache";

        if (isGastro)
            emit gastroDataReady(json);
        else
            emit shoppingDataReady(json);
        return;
    }

    // Fall back to bundled resource
    QFile resource(QStringLiteral(":/qml/pages/") + filename);
    if (resource.open(QIODevice::ReadOnly))
    {
        const QString json = QString::fromUtf8(resource.readAll());
        qInfo() << "Loaded" << filename << "from bundled resource";

        if (isGastro)
            emit gastroDataReady(json);
        else
            emit shoppingDataReady(json);
        return;
    }

    emit error(QStringLiteral("Could not load ") + filename);
}

void VenueDataLoader::saveToCache(const QString& filename, const QString& data)
{
    const QString path = cacheFilePath(filename);
    QDir().mkpath(QFileInfo(path).absolutePath());

    QFile file(path);
    if (file.open(QIODevice::WriteOnly))
    {
        file.write(data.toUtf8());
        qInfo() << "Cached" << filename << "to disk";
    }
    else
    {
        qWarning() << "Could not cache" << filename;
    }
}

QString VenueDataLoader::cacheFilePath(const QString& filename) const
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
           + QStringLiteral("/") + filename;
}
