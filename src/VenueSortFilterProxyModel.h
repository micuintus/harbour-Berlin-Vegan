#pragma once
#include "VenueModel.h"

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>
#include <QString>


class VenueSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(VenueModel* model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QString searchString MEMBER m_searchString WRITE setSearchString NOTIFY searchStringChanged)


public:
    VenueSortFilterProxyModel(QObject *parent = 0);

    VenueModel* model() const;


public slots:
    void setModel(VenueModel* model);
    void setSearchString(QString searchString);

signals:
    void modelChanged(VenueModel* model);
    void searchStringChanged(QString);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    QString m_searchString;
};
