#include "VenueSortFilterProxyModel.h"

VenueSortFilterProxyModel::VenueSortFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    sort(0);
}

VenueModel *VenueSortFilterProxyModel::model() const
{
    return qobject_cast<VenueModel*>(sourceModel());
}

void VenueSortFilterProxyModel::setModel(VenueModel *model)
{
    VenueModel *oldModel = qobject_cast<VenueModel*>(sourceModel());
    if (oldModel == model)
        return;

    if (oldModel) {
        disconnect(oldModel, SIGNAL(rolesChanged()),
                   this, SLOT(rolesChanged()));
    }

    setSourceModel(model);
    emit modelChanged(model);
}

void VenueSortFilterProxyModel::setSearchString(QString searchString)
{
    m_searchString = searchString;
    emit searchStringChanged(m_searchString);
    invalidateFilter();
}


bool VenueSortFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if ( sourceModel() != nullptr )
    {
        auto index = sourceModel()->index( source_row, 0, source_parent );
        if ( index.isValid() )
        {
            auto valueRole = index.data( VenueModel::VenueModelRoles::Name );
            if ( valueRole.isValid() )
            {
                auto value = valueRole.toString();
                return value.contains(m_searchString, Qt::CaseInsensitive);
            }
        }
    }

    return false;
}

bool VenueSortFilterProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    return QSortFilterProxyModel::lessThan(source_left, source_right);
}



