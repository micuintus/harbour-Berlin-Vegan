#pragma once
#include "VenueModel.h"

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>
#include <QString>
#include <QGeoCoordinate>

class VenueSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(VenueModel* model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QString searchString MEMBER m_searchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(QGeoCoordinate currentPosition MEMBER m_currentPosition WRITE setCurrentPosition)
    Q_PROPERTY(VenueModel::VenueModelCategoryFlags filterModelCategory MEMBER m_filterModelCategory WRITE setFilterModelCategory NOTIFY filterModelCategoryChanged)
    Q_PROPERTY(VenueSortFilterProxyModel::VenueVeganCategoryFlags filterVeganCategory READ filterVeganCategory NOTIFY filterVeganCategoryChanged)
    Q_PROPERTY(VenueSortFilterProxyModel::VenuePropertyFlags filterVenueProperty READ filterVenueProperty NOTIFY filterVenuePropertyChanged)
    Q_PROPERTY(bool filterFavorites MEMBER m_filterFavorites WRITE setFilterFavorites NOTIFY filterFavoritesChanged)

public:

    // See components-generic/VenueDescriptionAlgorithms.js:40
    enum VenueVeganCategoryFlag {
        Omnivore   = keyToFlag(1) | keyToFlag(2),
        Vegetarian = keyToFlag(3) | keyToFlag(4),
        Vegan      = keyToFlag(5)
    };
    Q_DECLARE_FLAGS(VenueVeganCategoryFlags, VenueVeganCategoryFlag)
    Q_FLAG(VenueVeganCategoryFlags)
    Q_ENUM(VenueVeganCategoryFlag)

    enum VenuePropertyFlag {
        Wlan                    = keyToFlag(VenueModel::Wlan - VenueModel::Wlan),
        HandicappedAccessible   = keyToFlag(VenueModel::HandicappedAccessible - VenueModel::Wlan),
        HandicappedAccessibleWc = keyToFlag(VenueModel::HandicappedAccessibleWc - VenueModel::Wlan),
        Catering                = keyToFlag(VenueModel::Catering - VenueModel::Wlan),
        Organic                 = keyToFlag(VenueModel::Organic - VenueModel::Wlan),
        GlutenFree              = keyToFlag(VenueModel::GlutenFree - VenueModel::Wlan),
        Delivery                = keyToFlag(VenueModel::Delivery - VenueModel::Wlan),
        Dog                     = keyToFlag(VenueModel::Dog - VenueModel::Wlan),
        ChildChair              = keyToFlag(VenueModel::ChildChair - VenueModel::Wlan)
    };
    Q_DECLARE_FLAGS(VenuePropertyFlags, VenuePropertyFlag)
    Q_FLAG(VenuePropertyFlags)
    Q_ENUM(VenuePropertyFlag)

    VenueSortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE VenueModel* model() const;
    Q_INVOKABLE VenueVeganCategoryFlags filterVeganCategory() const;
    Q_INVOKABLE VenuePropertyFlags filterVenueProperty() const;

    Q_INVOKABLE QVariantMap item(int row) const;
    Q_INVOKABLE void setVeganCategoryFilterFlag(VenueVeganCategoryFlag flag, bool on);
    Q_INVOKABLE void setVenuePropertyFilterFlag(VenuePropertyFlag flag, bool on);


public slots:
    void setModel(VenueModel* model);
    void setSearchString(QString searchString);
    void setFilterFavorites(bool);
    void setFilterModelCategory(VenueModel::VenueModelCategoryFlags category);
    void setCurrentPosition(QGeoCoordinate position);

signals:
    void modelChanged(VenueModel* model);
    void searchStringChanged(QString);
    void filterModelCategoryChanged();
    void filterVeganCategoryChanged();
    void filterVenuePropertyChanged();
    void filterFavoritesChanged(bool);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    void reSort();

    bool searchStringMatches(const QModelIndex& index) const;
    bool modelCategoryMatches(const QModelIndex& index) const;
    bool veganCategoryMatches(const QModelIndex& index) const;
    bool venuePropertyMatches(const QModelIndex& index) const;

    QString m_searchString;
    QGeoCoordinate m_currentPosition;
    VenueModel::VenueModelCategoryFlags m_filterModelCategory = VenueModel::FoodFlag;
    // positive filter
    VenueVeganCategoryFlags m_filterVeganCategory = { VenueVeganCategoryFlag::Vegan | VenueVeganCategoryFlag::Vegetarian | VenueVeganCategoryFlag::Omnivore };
    // negative filter
    VenuePropertyFlags m_filterVenueProperty = { };

    bool m_filterFavorites = false;
};
