#pragma once
#include "VenueModel.h"

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>
#include <QString>
#include <QGeoCoordinate>

constexpr inline int keyToFlag(int flag)
{
    return 1 << flag;
}

class VenueSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(VenueModel* model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QString searchString MEMBER m_searchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(QGeoCoordinate currentPosition MEMBER m_currentPosition WRITE setCurrentPosition)
    Q_PROPERTY(VenueModel::VenueModelCategory filterModelCategory MEMBER m_filterModelCategory WRITE setFilterModelCategory NOTIFY filterModelCategoryChanged)
    Q_PROPERTY(VenueSortFilterProxyModel::VenueVeganCategories filterVeganCategory READ filterVeganCategory NOTIFY filterVeganCategoryChanged)
    Q_PROPERTY(bool filterFavorites MEMBER m_filterFavorites WRITE setFilterFavorites NOTIFY filterFavoritesChanged)

public:

    // See components-generic/VenueDescriptionAlgorithms.js:40
    enum VenueVeganCategory {
        Omnivore   = keyToFlag(1) | keyToFlag(2),
        Vegetarian = keyToFlag(3) | keyToFlag(4),
        Vegan      = keyToFlag(5)
    };
    Q_DECLARE_FLAGS(VenueVeganCategories, VenueVeganCategory)
    Q_FLAG(VenueVeganCategories)
    Q_ENUM(VenueVeganCategory)

    VenueSortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE VenueModel* model() const;
    Q_INVOKABLE QVariantMap item(int row) const;
    VenueVeganCategories filterVeganCategory() const;
    Q_INVOKABLE void setVeganCategoryFilterFlag(VenueVeganCategory flag, bool on);

public slots:
    void setModel(VenueModel* model);
    void setSearchString(QString searchString);
    void setFilterFavorites(bool);
    void setFilterModelCategory(VenueModel::VenueModelCategory category);
    void setCurrentPosition(QGeoCoordinate position);

signals:
    void modelChanged(VenueModel* model);
    void searchStringChanged(QString);
    void filterModelCategoryChanged(VenueModel::VenueModelCategory);
    void filterFavoritesChanged(bool);
    void filterVeganCategoryChanged(VenueVeganCategories);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    void reSort();

    bool searchStringMatches(const QModelIndex& index) const;
    bool modelCategoryMatches(const QModelIndex& index) const;
    bool veganCategoryMatches(const QModelIndex& index) const;

    QString m_searchString;
    QGeoCoordinate m_currentPosition;
    VenueModel::VenueModelCategory m_filterModelCategory = VenueModel::Food;
    VenueVeganCategories m_filterVeganCategory = { VenueVeganCategory::Vegan | VenueVeganCategory::Vegetarian | VenueVeganCategory::Omnivore };
    bool m_filterFavorites = false;
};
