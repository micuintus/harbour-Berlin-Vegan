#pragma once

#include <QtCore/QHash>
#include <QtCore/QSet>
#include <QtQml/QJSValue>

#include <QStandardItemModel>
#include <QPersistentModelIndex>
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

#define ROLE_NAME_ID_PAIRS                                                \
    ROLE_NAME_ID_PAIR( id,                      ID                      ) \
    ROLE_NAME_ID_PAIR( name,                    Name                    ) \
    ROLE_NAME_ID_PAIR( venueType,               VenueTypeRole           ) \
    ROLE_NAME_ID_PAIR( venueSubType,            VenueSubTypeRole        ) \
    ROLE_NAME_ID_PAIR( favorite,                Favorite                ) \
    ROLE_NAME_ID_PAIR( street,                  Street                  ) \
    ROLE_NAME_ID_PAIR( comment,                 Description             ) \
    ROLE_NAME_ID_PAIR( commentEnglish,          DescriptionEn           ) \
    ROLE_NAME_ID_PAIR( review,                  Review                  ) \
    ROLE_NAME_ID_PAIR( website,                 Website                 ) \
    ROLE_NAME_ID_PAIR( telephone,               Telephone               ) \
    ROLE_NAME_ID_PAIR( pictures,                Pictures                ) \
                                                                          \
    /* Coordinates */                                                     \
    ROLE_NAME_ID_PAIR( latCoord,                LatCoord                ) \
    ROLE_NAME_ID_PAIR( longCoord,               LongCoord               ) \
                                                                          \
    /* Veg*an Category */                                                 \
    ROLE_NAME_ID_PAIR( vegan,                   VegCategory             ) \
                                                                          \
    /* Venue Properties */                                                \
    ROLE_NAME_ID_PAIR( organic,                 Organic                 ) \
    ROLE_NAME_ID_PAIR( handicappedAccessible,   HandicappedAccessible   ) \
    ROLE_NAME_ID_PAIR( delivery,                Delivery                ) \
                                                                          \
    /* Gastro Properties */                                               \
    ROLE_NAME_ID_PAIR( glutenFree,              GlutenFree              ) \
    ROLE_NAME_ID_PAIR( breakfast,               Breakfast               ) \
    ROLE_NAME_ID_PAIR( brunch,                  Brunch                  ) \
    ROLE_NAME_ID_PAIR( handicappedAccessibleWc, HandicappedAccessibleWc ) \
    ROLE_NAME_ID_PAIR( childChair,              ChildChair              ) \
    ROLE_NAME_ID_PAIR( dog,                     Dog                     ) \
    ROLE_NAME_ID_PAIR( catering,                Catering                ) \
    ROLE_NAME_ID_PAIR( wlan,                    Wlan                    ) \
    ROLE_NAME_ID_PAIR( seatsOutdoor,            SeatsOutdoor            ) \
    ROLE_NAME_ID_PAIR( seatsIndoor,             SeatsIndoor             ) \
                                                                          \
    /* OpeningHours */                                                    \
    ROLE_NAME_ID_PAIR( condensedOpeningHours,   CondensedOpeningHours   ) \
    ROLE_NAME_ID_PAIR( closesSoon,              ClosesSoon              ) \
    ROLE_NAME_ID_PAIR( open,                    Open                    ) \
    ROLE_NAME_ID_PAIR( otMon,                   OtMon                   ) \
    ROLE_NAME_ID_PAIR( otTue,                   OtTue                   ) \
    ROLE_NAME_ID_PAIR( otWed,                   OtWed                   ) \
    ROLE_NAME_ID_PAIR( otThu,                   OtThu                   ) \
    ROLE_NAME_ID_PAIR( otFri,                   OtFri                   ) \
    ROLE_NAME_ID_PAIR( otSat,                   OtSat                   ) \
    ROLE_NAME_ID_PAIR( otSun,                   OtSun                   ) \
    ROLE_NAME_ID_PAIR( openComment,             OpenComment             ) \
    ROLE_NAME_ID_PAIR( openCommentEnglish,      OpenCommentEn           ) \

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
        UserRole = Qt::UserRole,
#define ROLE_NAME_ID_PAIR(NAME, ID) ID,
        ROLE_NAME_ID_PAIRS
#undef ROLE_NAME_ID_PAIR

        // Nameless roles

        SimplifiedSearchName,
        SimplifiedSearchStreet,
        SimplifiedSearchDescription,
        SimplifiedSearchDescriptionEn,
        SimplifiedSearchReview,

        OpeningHours,
        OpeningMinutes,

        // Property ranges
        FirstVenuePropertyRole  = Organic,
        LastVenuePropertyRole   = Delivery,
        FirstGastroPropertyRole = GlutenFree,
        LastGastroPropertyRole  = Wlan
    };

    VenueModel(QObject *parent = 0);

    Q_INVOKABLE void importFromJson(const QJSValue&, VenueType venueType);
    Q_INVOKABLE void setFavorite(const QString& id, bool favorite = true);
    QHash<int, QByteArray> roleNames() const override;

    VenueTypeFlags loadedVenueType() const;

signals:
    void loadedVenueTypeChanged();

private:
    QModelIndex indexFromID(const QString& id) const;
    QStandardItem* jsonItem2QStandardItem(const QJSValue& from);

    VenueTypeFlags m_loadedVenueType;
};

Q_DECLARE_OPERATORS_FOR_FLAGS(VenueModel::VenueTypeFlags)
Q_DECLARE_OPERATORS_FOR_FLAGS(VenueModel::VenueSubTypeFlags)
