#pragma once

#include <QtCore/QHash>
#include <QtCore/QSet>
#include <QStandardItemModel>
#include <QtQml/QJSValue>

class QReadWriteLock;
class QQmlEngine;

constexpr inline int keyToFlag(const int key, const int keyOffset = 0)
{
    return 1 << (key - keyOffset);
}

class VenueModel : public QStandardItemModel
{
    Q_OBJECT

    Q_PROPERTY(VenueVenueTypeFlags loadedVenueType READ loadedVenueType NOTIFY loadedVenueTypeChanged)

public:
    enum VenueVegCategory
    {
        Unkown                  = 0,
        // Defined by the GastroLocations.json format
        // which comes from the berlin-vegan.de backend
        Omnivore                = 1,
        OmnivoreVeganDeclared   = 2,
        Vegetarian              = 3,
        VegetarianVeganDeclared = 4,
        Vegan                   = 5,
    };
    Q_ENUM(VenueVegCategory)

    enum VenueVenueType
    {
        Food,
        Shopping
    };
    Q_ENUM(VenueVenueType)

    enum VenueVenueTypeFlag
    {
        FoodFlag     = keyToFlag(VenueVenueType::Food),
        ShoppingFlag = keyToFlag(VenueVenueType::Shopping)
    };
    Q_DECLARE_FLAGS(VenueVenueTypeFlags, VenueVenueTypeFlag)
    Q_FLAG(VenueVenueTypeFlags)
    Q_ENUM(VenueVenueTypeFlag)

    enum VenueModelRoles
    {
        ID = Qt::UserRole + 1,
        Name,

        // Model Category
        VenueType,
        Favorite,

        Street,
        Description,
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
        SeatsOutdoor,
        SeatsIndoor,
        Dog,
        ChildChair,
        LastPropertyRole = ChildChair,

        // OpeningHours
        OtMon,
        OtTue,
        OtWed,
        OtThu,
        OtFri,
        OtSat,
        OtSun
    };

    VenueModel(QObject *parent = 0);

    Q_INVOKABLE void importFromJson(const QJSValue&, VenueVenueType);
    Q_INVOKABLE void setFavorite(const QString& id, bool favorite = true);
    QHash<int, QByteArray> roleNames() const override;

    VenueVenueTypeFlags loadedVenueType() const;

signals:
    void loadedVenueTypeChanged();

private:
    QModelIndex indexFromID(const QString& id) const;
    QStandardItem* jsonItem2QStandardItem(const QJSValue& from);
    VenueVenueTypeFlags m_loadedVenueType;

};

Q_DECLARE_OPERATORS_FOR_FLAGS(VenueModel::VenueVenueTypeFlags)
