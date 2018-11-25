#include "VenueSortProxyModel.h"
#include <algorithm>

VenueSortProxyModel::VenueSortProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    sort(0);
}

QVariantMap VenueSortProxyModel::item(int row) const
{
    QVariantMap ret;

        QModelIndex m = index(row, 0);
        if (!m.isValid())
            return ret;

        const auto mItemData = itemData(m);
        const auto mRoleNames = roleNames();

        for (auto it = mItemData.begin(); it != mItemData.end(); it++)
        {
            ret[mRoleNames[it.key()]] = it.value();
        };

    return ret;
}

void VenueSortProxyModel::setCurrentPosition(QGeoCoordinate position)
{
    if (m_currentPosition == position)
    {
        return;
    }

    m_currentPosition = position;
    reSort();
}

bool VenueSortProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
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

void VenueSortProxyModel::reSort()
{
    if (dynamicSortFilter()) {
        // Workaround: If dynamic_sortfilter == true, sort(0) will not (always)
        // result in d->sort() being called, but setDynamicSortFilter(true) will.
        setDynamicSortFilter(true);
    } else {
        sort(0);
    }
}

