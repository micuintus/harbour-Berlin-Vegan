#include "VenueSortFilterProxyModel.h"

VenueSortFilterProxyModel::VenueSortFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    sort(0);
}

com::cutehacks::gel::JsonListModel *VenueSortFilterProxyModel::model() const
{
    return qobject_cast<com::cutehacks::gel::JsonListModel*>(sourceModel());
}

void VenueSortFilterProxyModel::setModel(com::cutehacks::gel::JsonListModel *model)
{
    com::cutehacks::gel::JsonListModel *oldModel = qobject_cast<com::cutehacks::gel::JsonListModel*>(sourceModel());
    if (oldModel == model)
        return;

    if (oldModel) {
        disconnect(oldModel, SIGNAL(rolesChanged()),
                   this, SLOT(rolesChanged()));
    }

    setSourceModel(model);
    updateModel();
    connect(model, SIGNAL(rolesChanged()), this, SLOT(rolesChanged()));

    emit modelChanged(model);
}


void VenueSortFilterProxyModel::updateModel()
{

}


bool VenueSortFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}

bool VenueSortFilterProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    return QSortFilterProxyModel::lessThan(source_left, source_right);
}

QJSValue VenueSortFilterProxyModel::at(int row) const
{
    QModelIndex m = index(row, 0);
    QModelIndex source = mapToSource(m);
    return model()->at(source.row());
}

