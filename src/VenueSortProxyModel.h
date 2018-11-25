#pragma once
#include "VenueModel.h"

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>
#include <QString>
#include <QGeoCoordinate>

class VenueSortProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QGeoCoordinate currentPosition MEMBER m_currentPosition WRITE setCurrentPosition)

public:
    VenueSortProxyModel(QObject *parent = 0);
    Q_INVOKABLE QVariantMap item(int row) const;

public slots:
    void setCurrentPosition(QGeoCoordinate position);

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    void reSort();

    QGeoCoordinate m_currentPosition;

};

