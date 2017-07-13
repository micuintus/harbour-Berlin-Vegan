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
    Q_PROPERTY(VenueModel::VenueModelCategory filterModelCategory MEMBER m_filterModelCategory WRITE setFilterModelCategory NOTIFY filterModelCategoryChanged)
    Q_PROPERTY(bool filterFavorites MEMBER m_filterFavorites WRITE setFilterFavorites NOTIFY filterFavoritesChanged)

public:
    VenueSortFilterProxyModel(QObject *parent = 0);

    Q_INVOKABLE VenueModel* model() const;
    Q_INVOKABLE QVariantMap item(int row) const;

public slots:
    void setModel(VenueModel* model);
    void setSearchString(QString searchString);
    void setFilterModelCategory(VenueModel::VenueModelCategory category);
    void setFilterFavorites(bool);
    void setCurrentPosition(QGeoCoordinate position);

signals:
    void modelChanged(VenueModel* model);
    void searchStringChanged(QString);
    void filterModelCategoryChanged(VenueModel::VenueModelCategory);
    void filterFavoritesChanged(bool);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    void reSort();

    bool searchStringMatches(const QModelIndex& index) const;
    bool modelCategoryMatches(const QModelIndex& index) const;

    QString m_searchString;
    QGeoCoordinate m_currentPosition;
    VenueModel::VenueModelCategory m_filterModelCategory = VenueModel::Food;
    bool m_filterFavorites = false;
};
