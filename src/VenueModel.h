#pragma once

#include <QtCore/QHash>
#include <QtCore/QSet>
#include <QStandardItemModel>
#include <QtQml/QJSValue>

class QReadWriteLock;
class QQmlEngine;

class VenueModel : public QStandardItemModel
{
    Q_OBJECT

    Q_PROPERTY(LoadedVenueCategory loadedCategory READ loadedCategory NOTIFY loadedCategoryChanged)

public:
    enum VenueModelCategory
    {
        Food = 0x01,
        Shopping = 0x10
    };
    Q_DECLARE_FLAGS(LoadedVenueCategory, VenueModelCategory)
    Q_FLAG(LoadedVenueCategory)
    Q_ENUM(VenueModelCategory)


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

    LoadedVenueCategory loadedCategory() const;

signals:
    void loadedCategoryChanged(LoadedVenueCategory);

private:
    QModelIndex indexFromID(const QString& id) const;
    QStandardItem* jsonItem2QStandardItem(const QJSValue& from);
    LoadedVenueCategory m_loaded;

};

