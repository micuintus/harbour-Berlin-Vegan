#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QStringList>
#include <QSettings>

class FavoritesManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit FavoritesManager(QObject *parent = nullptr);

    Q_INVOKABLE QStringList getFavoriteIds() const;
    Q_INVOKABLE void addFavorite(const QString& id);
    Q_INVOKABLE void removeFavorite(const QString& id);
    Q_INVOKABLE bool isFavorite(const QString& id) const;

private:
    void save();
    void load();

    QStringList m_favoriteIds;
    QSettings m_settings;
};
