#pragma once

#include <QObject>
#include <QPointer>
#include <QVariantList>
#include <QGeoCoordinate>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QtQml/qqmlregistration.h>

// Nominatim forward-geocoding service for address search.
// Exposes search and geocode operations to QML as a singleton.
// Respects Nominatim's usage policy: one concurrent request, no burst.
class NominatimService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit NominatimService(QObject *parent = nullptr);

    // Autocomplete search: emits searchResults() with up to `limit` matches.
    // Appends ", Berlin, Deutschland" to the query to scope results.
    // Aborts any previous pending search before firing.
    Q_INVOKABLE void searchAddresses(const QString &query, int limit = 8);

    // Resolve a single address string to a coordinate.
    // Emits geocodeResult() on success, geocodeFailed() on error.
    Q_INVOKABLE void geocodeAddress(const QString &address);

    // Format a raw Nominatim display_name into a short "Street No, PLZ City" form.
    Q_INVOKABLE static QString parseDisplayName(const QString &displayName);

signals:
    void searchResults(const QVariantList &results);
    void geocodeResult(const QGeoCoordinate &coordinate);
    void geocodeFailed(const QString &error);

private:
    static const QByteArray &userAgent();
    void abortReply(QPointer<QNetworkReply> &reply);

    static constexpr QLatin1StringView BaseUrl{"https://nominatim.openstreetmap.org"};
    static constexpr QLatin1StringView SearchScope{", Berlin, Deutschland"};

    QNetworkAccessManager m_nam;
    QPointer<QNetworkReply> m_pendingSearch;
    QPointer<QNetworkReply> m_pendingGeocode;
};
