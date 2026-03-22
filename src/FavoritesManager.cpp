#include "FavoritesManager.h"

static const QString FAVORITES_KEY = QStringLiteral("favorites");

FavoritesManager::FavoritesManager(QObject *parent)
    : QObject(parent)
    , m_settings(QStringLiteral("berlin-vegan"), QStringLiteral("bvapp"))
{
    load();
}

QStringList FavoritesManager::getFavoriteIds() const
{
    return m_favoriteIds;
}

void FavoritesManager::addFavorite(const QString& id)
{
    if (!m_favoriteIds.contains(id))
    {
        m_favoriteIds.append(id);
        save();
    }
}

void FavoritesManager::removeFavorite(const QString& id)
{
    if (m_favoriteIds.removeAll(id) > 0)
    {
        save();
    }
}

bool FavoritesManager::isFavorite(const QString& id) const
{
    return m_favoriteIds.contains(id);
}

void FavoritesManager::save()
{
    m_settings.setValue(FAVORITES_KEY, m_favoriteIds);
}

void FavoritesManager::load()
{
    m_favoriteIds = m_settings.value(FAVORITES_KEY).toStringList();
}
