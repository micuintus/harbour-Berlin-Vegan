#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QGeoCoordinate>
#include <QJsonArray>
#include <QJsonObject>
#include <QtQml/qqmlregistration.h>

class OSMProvider : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit OSMProvider(QObject *parent = nullptr);

    bool loading() const { return m_loading; }

    // Load cached data immediately, then fetch fresh in background
    Q_INVOKABLE void loadMetroArea();
    Q_INVOKABLE void fetchNearby(const QGeoCoordinate& center, int radiusMeters = 5000);

signals:
    void venuesReady(const QJsonArray& venues);
    void loadingChanged();
    void error(const QString& message);

private:
    friend class TestOSMProvider;

    void fetchFromOverpass(const QString& query);
    void tryNextEndpoint(const QString& query, int endpointIndex);
    void parseResponse(const QByteArray& data);
    QJsonObject osmElementToVenue(const QJsonObject& element) const;
    int mapDietTagToVegCategory(const QString& dietVegan, const QString& dietVegetarian) const;

    // Cache
    void saveCache(const QByteArray& data);
    QByteArray loadCache() const;
    QString cachePath() const;

    QNetworkAccessManager m_networkManager;
    bool m_loading = false;
    bool m_cacheLoaded = false;
};
