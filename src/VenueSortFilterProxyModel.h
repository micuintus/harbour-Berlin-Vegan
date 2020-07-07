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
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString searchString MEMBER m_simplifiedSearchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(VenueModel::VenueTypeFlags filterVenueType MEMBER m_filterVenueType WRITE setFilterVenueType NOTIFY filterVenueTypeChanged)
    Q_PROPERTY(VenueModel::VenueSubTypeFlags filterVenueSubType READ filterVenueSubType NOTIFY filterVenueSubTypeChanged)
    Q_PROPERTY(VenueVegCategoryFlags filterVegCategory READ filterVegCategory NOTIFY filterVegCategoryChanged)
    Q_PROPERTY(VenuePropertyFlags filterVenueProperty READ filterVenueProperty NOTIFY filterVenuePropertyChanged)
    Q_PROPERTY(GastroPropertyFlags filterGastroProperty READ filterGastroProperty NOTIFY filterGastroPropertyChanged)
    Q_PROPERTY(bool filterOpenNow MEMBER m_filterOpenNow WRITE setFilterOpenNow NOTIFY filterOpenNowChanged)
    Q_PROPERTY(bool filterWithReview MEMBER m_filterWithReview WRITE setFilterWithReview NOTIFY filterWithReviewChanged)
    Q_PROPERTY(bool filterFavorites MEMBER m_filterFavorites WRITE setFilterFavorites NOTIFY filterFavoritesChanged)
    Q_PROPERTY(bool filterNew MEMBER m_filterNew WRITE setFilterNew NOTIFY filterNewChanged)
    Q_PROPERTY(int monthNew MEMBER m_monthNew WRITE setMonthNew NOTIFY monthNewChanged)

public:

    enum VenueVegCategoryFlag {
        OmnivorousFlag = enumValueToFlag(VenueModel::Omnivorous) | enumValueToFlag(VenueModel::OmnivorousVeganLabeled),
        VegetarianFlag = enumValueToFlag(VenueModel::Vegetarian) | enumValueToFlag(VenueModel::VegetarianVeganLabeled),
        VeganFlag      = enumValueToFlag(VenueModel::Vegan)
    };
    Q_DECLARE_FLAGS(VenueVegCategoryFlags, VenueVegCategoryFlag)
    Q_FLAG(VenueVegCategoryFlags)
    Q_ENUM(VenueVegCategoryFlag)

    // Property flags that apply to both shops and gastro venues
    enum VenuePropertyFlag {
        Organic                 = enumValueToFlag(VenueModel::Organic,                 VenueModel::FirstVenuePropertyRole),
        HandicappedAccessible   = enumValueToFlag(VenueModel::HandicappedAccessible,   VenueModel::FirstVenuePropertyRole),
        Delivery                = enumValueToFlag(VenueModel::Delivery,                VenueModel::FirstVenuePropertyRole),
    };
    Q_DECLARE_FLAGS(VenuePropertyFlags, VenuePropertyFlag)
    Q_FLAG(VenuePropertyFlags)
    Q_ENUM(VenuePropertyFlag)

    // Gastro only flags
    enum GastroPropertyFlag {
        GlutenFree              = enumValueToFlag(VenueModel::GlutenFree,              VenueModel::FirstGastroPropertyRole),
        Breakfast               = enumValueToFlag(VenueModel::Breakfast,               VenueModel::FirstGastroPropertyRole),
        Brunch                  = enumValueToFlag(VenueModel::Brunch,                  VenueModel::FirstGastroPropertyRole),
        HandicappedAccessibleWc = enumValueToFlag(VenueModel::HandicappedAccessibleWc, VenueModel::FirstGastroPropertyRole),
        ChildChair              = enumValueToFlag(VenueModel::ChildChair,              VenueModel::FirstGastroPropertyRole),
        Dog                     = enumValueToFlag(VenueModel::Dog,                     VenueModel::FirstGastroPropertyRole),
        Catering                = enumValueToFlag(VenueModel::Catering,                VenueModel::FirstGastroPropertyRole),
        Wlan                    = enumValueToFlag(VenueModel::Wlan,                    VenueModel::FirstGastroPropertyRole),
    };
    Q_DECLARE_FLAGS(GastroPropertyFlags, GastroPropertyFlag)
    Q_FLAG(GastroPropertyFlags)
    Q_ENUM(GastroPropertyFlag)

    Q_ENUMS(VenueModel::VenueSubTypeFlag)

    VenueSortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE VenueModel* model() const;
    int count() const;
    VenueVegCategoryFlags filterVegCategory() const;
    VenueModel::VenueSubTypeFlags filterVenueSubType() const;
    VenuePropertyFlags  filterVenueProperty() const;
    GastroPropertyFlags filterGastroProperty() const;

    Q_INVOKABLE VenueHandle* item(int row) const;
    Q_INVOKABLE void setVegCategoryFilterFlag(VenueVegCategoryFlag flag, bool on);
    Q_INVOKABLE void setVenuePropertyFilterFlag(VenuePropertyFlag flag, bool on);
    Q_INVOKABLE void setGastroPropertyFilterFlag(GastroPropertyFlag flag, bool on);

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
    void setFilterNew(bool);
    void setMonthNew(int);

private slots:
    void updateOpenState();

signals:
    void modelChanged();
    void countChanged();
    void searchStringChanged();
    void filterVenueTypeChanged();
    void filterVenueSubTypeChanged();
    void filterVegCategoryChanged();
    void filterVenuePropertyChanged();
    void filterGastroPropertyChanged();
    void filterOpenNowChanged();
    void filterWithReviewChanged();
    void filterFavoritesChanged();
    void filterNewChanged();
    void monthNewChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    // Need to override for opening hours
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;
    QVariant sourceData(const QModelIndex &index, int role = Qt::DisplayRole) const;

    void reSort();

    bool searchStringMatches(const QModelIndex& index) const;
    bool venueSubTypeMatches(const QModelIndex& index) const;
    std::pair<bool, VenueModel::VenueType>
    venueTypeMatches(const QModelIndex& indexe) const;
    bool vegCategoryMatches(const QModelIndex& index) const;
    bool venuePropertiesMatch(const QModelIndex& index) const;
    bool gastroPropertiesMatch(const QModelIndex& index) const;
    bool favoriteStatusMatches(const QModelIndex& index) const;

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
    GastroPropertyFlags m_filterGastroProperty = { };

    bool m_filterOpenNow    = false;
    bool m_filterWithReview = false;
    bool m_filterFavorites  = false;
    bool m_filterNew        {false};
    int m_monthNew{3};

    QTimer m_openStateUpdateTimer{this};

    char m_currendDayIndex = -1;
    unsigned m_currentMinute = 0;
};

