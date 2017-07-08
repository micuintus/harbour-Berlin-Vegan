#include "VenueSortFilterProxyModel.h"

VenueSortFilterProxyModel::VenueSortFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    sort(0);
}

VenueModel* VenueSortFilterProxyModel::model() const
{
    return qobject_cast<VenueModel*>(sourceModel());
}

QVariantMap VenueSortFilterProxyModel::item(int row) const
{
    QVariantMap ret;

    QModelIndex m = index(row, 0);
    QModelIndex source = mapToSource(m);
    QStandardItem* item = model()->itemFromIndex(source);
    const QHash<int, QByteArray>& roleNames = model()->roleNames();

    for (auto roleKey = roleNames.keyBegin(); roleKey != roleNames.keyEnd(); roleKey++)
    {
        ret.insert(roleNames[*roleKey], item->data(*roleKey));
    }

    return ret;
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

void VenueSortFilterProxyModel::setCurrentPosition(QGeoCoordinate position)
{
    m_currentPosition = position;
    reSort();
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
    QVariant leftLat, leftLong, rightLat, rightLong;

    if (   !m_currentPosition.isValid()
        || !source_left.isValid() || !source_right.isValid())
        goto err;

    leftLat   = source_left.data(VenueModel::VenueModelRoles::LatCoord);
    leftLong  = source_left.data(VenueModel::VenueModelRoles::LongCoord);
    rightLat  = source_right.data(VenueModel::VenueModelRoles::LatCoord);
    rightLong = source_right.data(VenueModel::VenueModelRoles::LongCoord);

    if (!leftLat.canConvert<double>() || !leftLong.canConvert<double>() ||
        !rightLat.canConvert<double>() || !rightLong.canConvert<double>())
        goto err;

    return   m_currentPosition.distanceTo(QGeoCoordinate(leftLat.toDouble(), leftLong.toDouble()))
           < m_currentPosition.distanceTo(QGeoCoordinate(rightLat.toDouble(), rightLong.toDouble()));

err:
    return QSortFilterProxyModel::lessThan(source_left, source_right);
}

void VenueSortFilterProxyModel::reSort()
{
    if (dynamicSortFilter()) {
        // Workaround: If dynamic_sortfilter == true, sort(0) will not (always)
        // result in d->sort() being called, but setDynamicSortFilter(true) will.
        setDynamicSortFilter(true);
    } else {
        sort(0);
    }
}



