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

    Q_PROPERTY(QString idAttribute READ idAttribute WRITE setIdAttribute NOTIFY idAttributeChanged)
    Q_PROPERTY(bool loaded READ loaded NOTIFY loadedChanged)

public:
    enum VenueModelRoles
    {
        Name = Qt::UserRole + 1,
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

    Q_INVOKABLE void importFromJson(const QJSValue&);
    QHash<int, QByteArray> roleNames() const override;
    QString idAttribute() const;

    bool loaded() const;


public slots:
    void setIdAttribute(QString idAttribute);


signals:
    void idAttributeChanged(QString idAttribute);
    void loadedChanged(bool);

private:
    QStandardItem* jsonItem2QStandardItem(const QJSValue& from);
    QString m_idAttribute;
    bool m_loaded;
};

