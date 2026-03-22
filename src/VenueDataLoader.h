#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QNetworkAccessManager>
#include <QUrl>

class VenueModel;

class VenueDataLoader : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit VenueDataLoader(QObject *parent = nullptr);

    Q_INVOKABLE void loadGastroVenues();
    Q_INVOKABLE void loadShoppingVenues();

    bool loading() const { return m_pendingRequests > 0; }

signals:
    void gastroDataReady(const QString& json);
    void shoppingDataReady(const QString& json);
    void loadingChanged();
    void error(const QString& message);

private:
    void fetchFromNetwork(const QUrl& url, bool isGastro);
    void loadFromCache(const QString& filename, bool isGastro);
    void saveToCache(const QString& filename, const QString& data);
    QString cacheFilePath(const QString& filename) const;

    QNetworkAccessManager m_networkManager;
    int m_pendingRequests = 0;
};
