#pragma once
#include "VenueModel.h"

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>
#include <QString>
#include <QGeoCoordinate>

class VenueSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(VenueModel* model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QString searchString MEMBER m_searchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(QGeoCoordinate currentPosition MEMBER m_currentPosition WRITE setCurrentPosition)


public:
    VenueSortFilterProxyModel(QObject *parent = 0);

    VenueModel* model() const;


public slots:
    void setModel(VenueModel* model);
    void setSearchString(QString searchString);
    void setCurrentPosition(QGeoCoordinate position);

signals:
    void modelChanged(VenueModel* model);
    void searchStringChanged(QString);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    void reSort();

    QString m_searchString;
    QGeoCoordinate m_currentPosition;
};
