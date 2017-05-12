#pragma once

#include <QtCore/QSortFilterProxyModel>
#include <QtQml/QJSValue>

#include <3rdparty/Cutehacks/gel/jsonlistmodel.h>


class VenueSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(com::cutehacks::gel::JsonListModel* model READ model WRITE setModel NOTIFY modelChanged)

public:
    VenueSortFilterProxyModel(QObject *parent = 0);

    com::cutehacks::gel::JsonListModel* model() const;

    Q_INVOKABLE QJSValue at(int) const;


public slots:
    void setModel(com::cutehacks::gel::JsonListModel* model);

signals:
    void modelChanged(com::cutehacks::gel::JsonListModel* model);

protected:
    void updateModel();
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

};
