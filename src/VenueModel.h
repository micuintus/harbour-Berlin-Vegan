#pragma once

#include <QtCore/QHash>
#include <QtCore/QSet>
#include <QtQml/QJSValue>

#include <QStandardItemModel>

#include <QTimer>


class QReadWriteLock;
class QQmlEngine;

// Turn a value of an enum to a bitmask, which has only the bit at the position of
// that enum value set to 1. At your option, rebase the enumValue to enumOffset.
constexpr inline int enumValueToFlag(const int enumValue, const int enumOffset = 0)
{
    return 1 << (enumValue - enumOffset);
}

inline QString simplifySearchString(const QString searchString)
{
    auto simplifiedString = searchString.toLower();
    return simplifiedString.replace(L'é', QLatin1Char('e'), Qt::CaseInsensitive)
                           .replace(L'è', QLatin1Char('e'), Qt::CaseInsensitive)
                           .replace(L'ê', QLatin1Char('e'), Qt::CaseInsensitive)
                           .replace(L'ü', QLatin1Char('u'), Qt::CaseInsensitive)
                           .replace(L'ö', QLatin1Char('o'), Qt::CaseInsensitive)
                           .replace(L'ä', QLatin1Char('a'), Qt::CaseInsensitive)
                           .replace(QLatin1Char('c'), QLatin1Char('k'), Qt::CaseInsensitive)
                           .replace(L'ß', QLatin1String("ss"), Qt::CaseInsensitive);
}

class VenueModel : public QStandardItemModel
{
    Q_OBJECT

    Q_PROPERTY(VenueTypeFlags loadedVenueType READ loadedVenueType NOTIFY loadedVenueTypeChanged)

public:
    enum VenueVegCategory
    {
        Unknown                 = 0,
        // Defined by the GastroLocations.json format
        // which comes from the berlin-vegan.de backend
        Omnivorous              = 1,
        OmnivorousVeganLabeled  = 2,
        Vegetarian              = 3,
        VegetarianVeganLabeled  = 4,
        Vegan                   = 5,
    };
    Q_ENUM(VenueVegCategory)

    enum VenueType
    {
        Gastro,
        Shop,
    };
    Q_ENUM(VenueType)

    enum VenueTypeFlag
    {
        GastroFlag = enumValueToFlag(VenueType::Gastro),
        ShopFlag  = enumValueToFlag(VenueType::Shop)
    };
    Q_DECLARE_FLAGS(VenueTypeFlags, VenueTypeFlag)
    Q_FLAG(VenueTypeFlags)
    Q_ENUM(VenueTypeFlag)

    enum VenueSubTypeFlag
    {
        NoneFlag          = enumValueToFlag(0),

        // Gastro flags
        RestaurantFlag    = enumValueToFlag(1),
        FastFoodFlag      = enumValueToFlag(2),
        CafeFlag          = enumValueToFlag(3),
        IceCreamFlag      = enumValueToFlag(4),
        BarFlag           = enumValueToFlag(5),

        // Shop flags
        FoodsFlag         = enumValueToFlag(6),
        ClothingFlag      = enumValueToFlag(7),
        ToiletriesFlag    = enumValueToFlag(8),
        SupermarketFlag   = enumValueToFlag(9),
        HairdressersFlag  = enumValueToFlag(10),
        SportsFlag        = enumValueToFlag(11),
        TattoostudioFlag  = enumValueToFlag(12),
        AccommodationFlag = enumValueToFlag(13),
    };
    Q_DECLARE_FLAGS(VenueSubTypeFlags, VenueSubTypeFlag)
    Q_FLAG(VenueSubTypeFlags)
    Q_ENUM(VenueSubTypeFlag)

    enum VenueModelRoles
    {
        ID = Qt::UserRole + 1,
        Name,
        SimplifiedSearchName,

        // Model Category
        VenueTypeRole,
        // Restaurant, Imbiss, Cafe, Eiscafe
        VenueSubTypeRole,
        Favorite,

        Street,
        SimplifiedSearchStreet,
        Description,
        SimplifiedSearchDescription,
        DescriptionEn,
        SimplifiedSearchDescriptionEn,
        Review,
        SimplifiedSearchReview,
        Website,
        Telephone,
        Pictures,

        // Coordinates
        LatCoord,
        LongCoord,

        // Properties
        FirstPropertyRole,
        Wlan = FirstPropertyRole,
        VegCategory,
        HandicappedAccessible,
        HandicappedAccessibleWc,
        Catering,
        Organic,
        GlutenFree,
        Delivery,
        Breakfast,
        Brunch,
        SeatsOutdoor,
        SeatsIndoor,
        Dog,
        ChildChair,
        LastPropertyRole = ChildChair,

        // OpeningHours
        Open,
        ClosesSoon,
        CondensedOpeningHours,
        OpeningMinutes,
        OtMon,
        OtTue,
        OtWed,
        OtThu,
        OtFri,
        OtSat,
        OtSun
    };

    VenueModel(QObject *parent = 0);

    Q_INVOKABLE void importFromJson(const QJSValue&, VenueType venueType);
    Q_INVOKABLE void setFavorite(const QString& id, bool favorite = true);
    QHash<int, QByteArray> roleNames() const override;

    VenueTypeFlags loadedVenueType() const;

signals:
    void loadedVenueTypeChanged();

private slots:
    void updateOpenState();

private:
    // Need to override for opening hours
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    QModelIndex indexFromID(const QString& id) const;
    QStandardItem* jsonItem2QStandardItem(const QJSValue& from);

    QTimer m_openStateUpdateTimer;

    VenueTypeFlags m_loadedVenueType;
    char m_currendDayIndex = -1;
    unsigned m_currentMinute = 0;

};

Q_DECLARE_OPERATORS_FOR_FLAGS(VenueModel::VenueTypeFlags)
Q_DECLARE_OPERATORS_FOR_FLAGS(VenueModel::VenueSubTypeFlags)
