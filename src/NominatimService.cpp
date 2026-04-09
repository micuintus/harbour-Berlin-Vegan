#include "NominatimService.h"

#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QUrlQuery>

#ifndef APP_VERSION
#  define APP_VERSION "0.0.0"
#endif

const QByteArray &NominatimService::userAgent()
{
    static const QByteArray ua = QByteArrayLiteral("BerlinVegan-App/") + APP_VERSION;
    return ua;
}

NominatimService::NominatimService(QObject *parent)
    : QObject(parent)
{
}

void NominatimService::abortReply(QPointer<QNetworkReply> &reply)
{
    if (reply) {
        QNetworkReply *r = reply.data();
        reply = nullptr;   // clear before abort() so the finished lambda ignores this reply
        r->abort();        // may emit finished() synchronously — lambda sees nullptr and returns
        r->deleteLater();
    }
}

void NominatimService::searchAddresses(const QString &query, int limit)
{
    if (query.trimmed().isEmpty() || query.length() < 2) {
        emit searchResults({});
        return;
    }

    QUrl url(QString(BaseUrl) + QStringLiteral("/search"));
    QUrlQuery urlQuery;
    urlQuery.addQueryItem(QStringLiteral("q"), query + QString(SearchScope));
    urlQuery.addQueryItem(QStringLiteral("format"), QStringLiteral("json"));
    urlQuery.addQueryItem(QStringLiteral("limit"), QString::number(limit));
    urlQuery.addQueryItem(QStringLiteral("addressdetails"), QStringLiteral("1"));
    urlQuery.addQueryItem(QStringLiteral("accept-language"), QStringLiteral("de"));
    url.setQuery(urlQuery);

    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", userAgent());
    request.setTransferTimeout(15000);

    abortReply(m_pendingSearch);

    QNetworkReply *reply = m_nam.get(request);
    m_pendingSearch = reply;
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply == m_pendingSearch)
            m_pendingSearch = nullptr;
        if (reply->error() != QNetworkReply::NoError) {
            if (reply->error() != QNetworkReply::OperationCanceledError)
                emit searchResults({});
            return;
        }

        const QJsonArray arr = QJsonDocument::fromJson(reply->readAll()).array();
        QVariantList results;
        results.reserve(arr.size());
        for (const QJsonValue &val : arr)
            results.append(val.toObject().toVariantMap());
        emit searchResults(results);
    });
}

void NominatimService::geocodeAddress(const QString &address)
{
    if (address.trimmed().isEmpty()) {
        emit geocodeFailed(QStringLiteral("Empty address"));
        return;
    }

    QUrl url(QString(BaseUrl) + QStringLiteral("/search"));
    QUrlQuery urlQuery;
    urlQuery.addQueryItem(QStringLiteral("q"), address + QString(SearchScope));
    urlQuery.addQueryItem(QStringLiteral("format"), QStringLiteral("json"));
    urlQuery.addQueryItem(QStringLiteral("limit"), QStringLiteral("1"));
    urlQuery.addQueryItem(QStringLiteral("addressdetails"), QStringLiteral("0"));
    url.setQuery(urlQuery);

    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", userAgent());
    request.setTransferTimeout(15000);

    abortReply(m_pendingGeocode);

    QNetworkReply *reply = m_nam.get(request);
    m_pendingGeocode = reply;
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply == m_pendingGeocode)
            m_pendingGeocode = nullptr;
        if (reply->error() != QNetworkReply::NoError) {
            if (reply->error() != QNetworkReply::OperationCanceledError)
                emit geocodeFailed(reply->errorString());
            return;
        }

        const QJsonArray arr = QJsonDocument::fromJson(reply->readAll()).array();
        if (arr.isEmpty()) {
            emit geocodeFailed(QStringLiteral("Address not found"));
            return;
        }

        const QJsonObject result = arr.first().toObject();
        bool latOk = false, lonOk = false;
        const double lat = result.value(QStringLiteral("lat")).toString().toDouble(&latOk);
        const double lon = result.value(QStringLiteral("lon")).toString().toDouble(&lonOk);

        if (latOk && lonOk)
            emit geocodeResult(QGeoCoordinate(lat, lon));
        else
            emit geocodeFailed(QStringLiteral("Address not found"));
    });
}

QString NominatimService::parseDisplayName(const QString &displayName)
{
    const QStringList parts = displayName.split(QStringLiteral(", "), Qt::SkipEmptyParts);
    if (parts.size() < 3)
        return displayName;

    // Nominatim typical order: "Street, HouseNum, Suburb, District, City, State, PostalCode, Country"
    const QString &street = parts[0];
    QString houseNumber;
    QString postalCode;
    QString city;

    if (parts.size() > 1 && !parts[1].isEmpty() && parts[1][0].isDigit())
        houseNumber = parts[1];

    if (parts.size() >= 3) {
        const QString &candidate = parts[parts.size() - 2];
        static const QRegularExpression postalRe(QStringLiteral("^\\d{4,5}$"));
        if (postalRe.match(candidate).hasMatch())
            postalCode = candidate;
    }

    if (parts.size() >= 5)
        city = parts[parts.size() - 4];
    else if (parts.size() >= 3)
        city = parts[parts.size() - 3];

    QString result = street;
    if (!houseNumber.isEmpty())
        result += QLatin1Char(' ') + houseNumber;
    if (!postalCode.isEmpty() || !city.isEmpty())
        result += QStringLiteral(", ") + (postalCode.isEmpty() ? QString() : postalCode + QLatin1Char(' ')) + city;
    return result;
}
