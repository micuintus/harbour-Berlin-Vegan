#pragma once

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>

#include "VenueModel.h"


class VenueSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(VenueModel* model READ model WRITE setModel NOTIFY modelChanged)

public:
    VenueSortFilterProxyModel(QObject *parent = 0);

    VenueModel* model() const;

    Q_INVOKABLE QJSValue at(int) const;


public slots:
    void setModel(VenueModel* model);

signals:
    void modelChanged(VenueModel* model);

protected:
    void updateModel();
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

};
