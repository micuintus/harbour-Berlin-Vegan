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

    Q_PROPERTY(VenueModelCategoryFlags loadedCategory READ loadedCategory NOTIFY loadedCategoryChanged)

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

    enum VenueModelCategory
    {
        Food,
        Shopping
    };
    Q_ENUM(VenueModelCategory)

    enum VenueModelCategoryFlag
    {
        FoodFlag = keyToFlag(VenueModelCategory::Food),
        ShoppingFlag = keyToFlag(VenueModelCategory::Shopping)
    };
    Q_DECLARE_FLAGS(VenueModelCategoryFlags, VenueModelCategoryFlag)
    Q_FLAG(VenueModelCategoryFlags)
    Q_ENUM(VenueModelCategoryFlag)

    enum VenueModelRoles
    {
        ID = Qt::UserRole + 1,
        Name,

        // Model Category
        ModelCategory,
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

    Q_INVOKABLE void importFromJson(const QJSValue&, VenueModelCategory);
    Q_INVOKABLE void setFavorite(const QString& id, bool favorite = true);
    QHash<int, QByteArray> roleNames() const override;

    VenueModelCategoryFlags loadedCategory() const;

signals:
    void loadedCategoryChanged();

private:
    QModelIndex indexFromID(const QString& id) const;
    QStandardItem* jsonItem2QStandardItem(const QJSValue& from);
    VenueModelCategoryFlags m_loaded;

};

Q_DECLARE_OPERATORS_FOR_FLAGS(VenueModel::VenueModelCategoryFlags)
