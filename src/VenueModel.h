#pragma once

#include <QtCore/QHash>
#include <QtCore/QSet>
#include <QStandardItemModel>
#include <QtQml/QJSValue>

class QReadWriteLock;
class QQmlEngine;

constexpr inline int keyToFlag(int key)
{
    return 1 << key;
}

class VenueModel : public QStandardItemModel
{
    Q_OBJECT

    Q_PROPERTY(VenueModelCategoryFlags loadedCategory READ loadedCategory NOTIFY loadedCategoryChanged)

public:
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
        Wlan,
        VeganCategory,
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
