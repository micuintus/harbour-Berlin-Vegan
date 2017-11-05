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
    Q_PROPERTY(VenueModel::VenueTypeFlags filterVenueType MEMBER m_filterVenueType WRITE setFilterVenueType NOTIFY filterVenueTypeChanged)
    Q_PROPERTY(VenueVegCategoryFlags filterVegCategory READ filterVegCategory NOTIFY filterVegCategoryChanged)
    Q_PROPERTY(VenuePropertyFlags filterVenueProperty READ filterVenueProperty NOTIFY filterVenuePropertyChanged)
    Q_PROPERTY(bool filterFavorites MEMBER m_filterFavorites WRITE setFilterFavorites NOTIFY filterFavoritesChanged)

public:

    enum VenueVegCategoryFlag {
        OmnivoreFlag   = enumValueToFlag(VenueModel::Omnivore)   | enumValueToFlag(VenueModel::OmnivoreVeganDeclared),
        VegetarianFlag = enumValueToFlag(VenueModel::Vegetarian) | enumValueToFlag(VenueModel::VegetarianVeganDeclared),
        VeganFlag      = enumValueToFlag(VenueModel::Vegan)
    };
    Q_DECLARE_FLAGS(VenueVegCategoryFlags, VenueVegCategoryFlag)
    Q_FLAG(VenueVegCategoryFlags)
    Q_ENUM(VenueVegCategoryFlag)

    enum VenuePropertyFlag {
                                  // Make sure we start with bit 0 and not with bit VenueModel::FirstPropertyRole
        Wlan                    = enumValueToFlag(VenueModel::Wlan,                    VenueModel::FirstPropertyRole),
        HandicappedAccessible   = enumValueToFlag(VenueModel::HandicappedAccessible,   VenueModel::FirstPropertyRole),
        HandicappedAccessibleWc = enumValueToFlag(VenueModel::HandicappedAccessibleWc, VenueModel::FirstPropertyRole),
        Catering                = enumValueToFlag(VenueModel::Catering,                VenueModel::FirstPropertyRole),
        Organic                 = enumValueToFlag(VenueModel::Organic,                 VenueModel::FirstPropertyRole),
        GlutenFree              = enumValueToFlag(VenueModel::GlutenFree,              VenueModel::FirstPropertyRole),
        Delivery                = enumValueToFlag(VenueModel::Delivery,                VenueModel::FirstPropertyRole),
        Dog                     = enumValueToFlag(VenueModel::Dog,                     VenueModel::FirstPropertyRole),
        ChildChair              = enumValueToFlag(VenueModel::ChildChair,              VenueModel::FirstPropertyRole),
    };
    Q_DECLARE_FLAGS(VenuePropertyFlags, VenuePropertyFlag)
    Q_FLAG(VenuePropertyFlags)
    Q_ENUM(VenuePropertyFlag)

    VenueSortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE VenueModel* model() const;
    Q_INVOKABLE VenueVegCategoryFlags filterVegCategory() const;
    Q_INVOKABLE VenuePropertyFlags filterVenueProperty() const;

    Q_INVOKABLE QVariantMap item(int row) const;
    Q_INVOKABLE void setVegCategoryFilterFlag(VenueVegCategoryFlag flag, bool on);
    Q_INVOKABLE void setVenuePropertyFilterFlag(VenuePropertyFlag flag, bool on);


public slots:
    void setModel(VenueModel* model);
    void setSearchString(QString searchString);
    void setFilterFavorites(bool);
    void setFilterVenueType(VenueModel::VenueTypeFlags);
    void setCurrentPosition(QGeoCoordinate position);

signals:
    void modelChanged(VenueModel* model);
    void searchStringChanged(QString);
    void filterVenueTypeChanged();
    void filterVegCategoryChanged();
    void filterVenuePropertyChanged();
    void filterFavoritesChanged(bool);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    void reSort();

    bool searchStringMatches(const QModelIndex& index) const;
    bool favoriteStatusMatches(const QModelIndex& index) const;
    bool venueTypeMatches(const QModelIndex& index) const;
    bool vegCategoryMatches(const QModelIndex& index) const;
    bool venuePropertiesMatch(const QModelIndex& index) const;

    QString m_searchString;
    QGeoCoordinate m_currentPosition;
    VenueModel::VenueTypeFlags m_filterVenueType = VenueModel::FoodFlag;
    // positive filter
    VenueVegCategoryFlags m_filterVegCategory = { VeganFlag | VegetarianFlag | OmnivoreFlag };
    // negative filter
    VenuePropertyFlags m_filterVenueProperty = { };

    bool m_filterFavorites = false;
};
