#pragma once
#include "VenueModel.h"
#include "VenueHandle.h"

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>
#include <QString>
#include <QGeoCoordinate>

class VenueSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(VenueModel* model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QGeoCoordinate currentPosition MEMBER m_currentPosition WRITE setCurrentPosition)

    Q_PROPERTY(QString searchString MEMBER m_simplifiedSearchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(VenueModel::VenueTypeFlags filterVenueType MEMBER m_filterVenueType WRITE setFilterVenueType NOTIFY filterVenueTypeChanged)
    Q_PROPERTY(VenueModel::VenueSubTypeFlags filterVenueSubType READ filterVenueSubType NOTIFY filterVenueSubTypeChanged)
    Q_PROPERTY(VenueVegCategoryFlags filterVegCategory READ filterVegCategory NOTIFY filterVegCategoryChanged)
    Q_PROPERTY(VenuePropertyFlags filterVenueProperty READ filterVenueProperty NOTIFY filterVenuePropertyChanged)
    Q_PROPERTY(bool filterOpenNow MEMBER m_filterOpenNow WRITE setFilterOpenNow NOTIFY filterOpenNowChanged)
    Q_PROPERTY(bool filterWithReview MEMBER m_filterWithReview WRITE setFilterWithReview NOTIFY filterWithReviewChanged)
    Q_PROPERTY(bool filterFavorites MEMBER m_filterFavorites WRITE setFilterFavorites NOTIFY filterFavoritesChanged)

public:

    enum VenueVegCategoryFlag {
        OmnivorousFlag = enumValueToFlag(VenueModel::Omnivorous) | enumValueToFlag(VenueModel::OmnivorousVeganLabeled),
        VegetarianFlag = enumValueToFlag(VenueModel::Vegetarian) | enumValueToFlag(VenueModel::VegetarianVeganLabeled),
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
        Breakfast               = enumValueToFlag(VenueModel::Breakfast,               VenueModel::FirstPropertyRole),
        Brunch                  = enumValueToFlag(VenueModel::Brunch,                  VenueModel::FirstPropertyRole),
        Dog                     = enumValueToFlag(VenueModel::Dog,                     VenueModel::FirstPropertyRole),
        ChildChair              = enumValueToFlag(VenueModel::ChildChair,              VenueModel::FirstPropertyRole),
    };
    Q_DECLARE_FLAGS(VenuePropertyFlags, VenuePropertyFlag)
    Q_FLAG(VenuePropertyFlags)
    Q_ENUM(VenuePropertyFlag)

    Q_ENUMS(VenueModel::VenueSubTypeFlag)

    VenueSortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE VenueModel* model() const;
    Q_INVOKABLE VenueVegCategoryFlags filterVegCategory() const;
    Q_INVOKABLE VenueModel::VenueSubTypeFlags filterVenueSubType() const;
    Q_INVOKABLE VenuePropertyFlags filterVenueProperty() const;

    Q_INVOKABLE VenueHandle* item(int row) const;
    Q_INVOKABLE void setVegCategoryFilterFlag(VenueVegCategoryFlag flag, bool on);
    Q_INVOKABLE void setVenuePropertyFilterFlag(VenuePropertyFlag flag, bool on);
    // Note: Int because of QTBUG-58454:
    // Q_ENUMs from one class cannot be used as a Q_INVOKABLE function parameter of another class
    Q_INVOKABLE void setVenueSubTypeFilterFlag(int flag, bool on);


public slots:
    void setModel(VenueModel* model);
    void setSearchString(QString searchString);
    void setFilterVenueType(VenueModel::VenueTypeFlags);
    void setCurrentPosition(QGeoCoordinate position);
    void setFilterOpenNow(bool);
    void setFilterWithReview(bool);
    void setFilterFavorites(bool);

signals:
    void modelChanged();
    void searchStringChanged();
    void filterVenueTypeChanged();
    void filterVenueSubTypeChanged();
    void filterVegCategoryChanged();
    void filterVenuePropertyChanged();
    void filterOpenNowChanged();
    void filterWithReviewChanged();
    void filterFavoritesChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    void reSort();

    bool searchStringMatches(const QModelIndex& index) const;
    bool venueSubTypeMatches(const QModelIndex& index) const;
    bool venueTypeMatches(const QModelIndex& indexe) const;
    bool vegCategoryMatches(const QModelIndex& index) const;
    bool venuePropertiesMatch(const QModelIndex& index) const;
    bool favoriteStatusMatches(const QModelIndex& index) const;
    bool openNow(const QModelIndex& index) const;
    bool hasReview(const QModelIndex& index) const;

    template <typename FilterFlags, typename SignalType>
    void setFilterFlag(FilterFlags& filterFlagMask, const typename FilterFlags::enum_type flag, const bool on, SignalType changedSignal);

    QString m_simplifiedSearchString;
    QGeoCoordinate m_currentPosition;

    // Positive filter / OR filter: Filter in if any category matches
    VenueModel::VenueTypeFlags m_filterVenueType = VenueModel::GastroFlag;
                                                         // Gastro flags
    VenueModel::VenueSubTypeFlags m_filterVenueSubType = { VenueModel::RestaurantFlag
                                                         | VenueModel::FastFoodFlag
                                                         | VenueModel::CafeFlag
                                                         | VenueModel::BarFlag
                                                         | VenueModel::IceCreamFlag
                                                         // Shopping flags
                                                         | VenueModel::FoodsFlag
                                                         | VenueModel::ClothingFlag
                                                         | VenueModel::ToiletriesFlag
                                                         | VenueModel::SupermarketFlag
                                                         | VenueModel::HairdressersFlag
                                                         | VenueModel::SportsFlag
                                                         | VenueModel::TattoostudioFlag
                                                         | VenueModel::AccommodationFlag};

    VenueVegCategoryFlags m_filterVegCategory = { VeganFlag | VegetarianFlag | OmnivorousFlag };
    // Negative filter / AND filter: Only filter in if all categories match
    VenuePropertyFlags m_filterVenueProperty = { };

    bool m_filterOpenNow    = false;
    bool m_filterWithReview = false;
    bool m_filterFavorites  = false;
};

