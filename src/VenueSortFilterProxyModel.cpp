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

    const auto model = this->model();
    if (model)
    {
        QModelIndex m = index(row, 0);
        QModelIndex source = mapToSource(m);
        QStandardItem* item = model->itemFromIndex(source);

        if (item)
        {
            const QHash<int, QByteArray>& roleNames = model->roleNames();
            for (auto roleKey = roleNames.keyBegin(); roleKey != roleNames.keyEnd(); roleKey++)
            {
                ret.insert(roleNames[*roleKey], item->data(*roleKey));
            }
        }
    }

    return ret;
}

VenueSortFilterProxyModel::VenueVeganCategories VenueSortFilterProxyModel::filterVeganCategory() const
{
    return m_filterVeganCategory;
}

VenueSortFilterProxyModel::VenueProperties VenueSortFilterProxyModel::filterVenueProperty() const
{
    return m_filterVenueProperty;
}

void VenueSortFilterProxyModel::setVeganCategoryFilterFlag(VenueVeganCategory flag, bool on)
{
    if (on)
    {
        m_filterVeganCategory |= flag;
    }
    else
    {
        m_filterVeganCategory &= ~flag;
    }

    emit filterVeganCategoryChanged(m_filterVeganCategory);
    invalidateFilter();
}

void VenueSortFilterProxyModel::setVenuePropertyFilterFlag(VenueProperty flag, bool on)
{
    if (on)
    {
        m_filterVenueProperty |= flag;
    }
    else
    {
        m_filterVenueProperty &= ~flag;
    }

    emit filterVenuePropertyChanged(m_filterVenueProperty);
    invalidateFilter();
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

void VenueSortFilterProxyModel::setFilterModelCategory(VenueModel::VenueModelCategory category)
{
    m_filterModelCategory = category;
    emit filterModelCategoryChanged(m_filterModelCategory);
    invalidateFilter();
}

void VenueSortFilterProxyModel::setFilterFavorites(bool filterFavorites)
{
    m_filterFavorites = filterFavorites;
    emit filterFavoritesChanged(m_filterFavorites);
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
        if (index.isValid())
        {
            return searchStringMatches(index)
                && modelCategoryMatches(index)
                && veganCategoryMatches(index)
                && venuePropertyMatches(index);
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

bool VenueSortFilterProxyModel::searchStringMatches(const QModelIndex &index) const
{
    const auto valueRole = index.data( VenueModel::VenueModelRoles::Name );
    if (valueRole.isValid() && valueRole.canConvert<QString>())
    {
        const auto value = valueRole.toString();
        return value.contains(m_searchString, Qt::CaseInsensitive);
    }

    return false;
}

bool VenueSortFilterProxyModel::modelCategoryMatches(const QModelIndex &index) const
{
    if (m_filterFavorites)
    {
        const auto valueRole = index.data( VenueModel::VenueModelRoles::Favorite);
        if (valueRole.isValid() && valueRole.canConvert<bool>())
        {
            return valueRole.toBool();
        }
        else
        {
            return false;
        }
    }
    else
    {
        const auto valueRole = index.data( VenueModel::VenueModelRoles::ModelCategory );
        if (valueRole.isValid() && valueRole.canConvert<int>())
        {
            const auto value = valueRole.toInt();
            return value == m_filterModelCategory;
        }
        else
        {
            return false;
        }
    }
}

bool VenueSortFilterProxyModel::veganCategoryMatches(const QModelIndex &index) const
{
    const auto valueRole = index.data( VenueModel::VenueModelRoles::VeganCategory );
    if (valueRole.isValid() && valueRole.canConvert<int>())
    {
        const auto value = valueRole.toInt();
        return m_filterVeganCategory.testFlag(VenueSortFilterProxyModel::VenueVeganCategory(keyToFlag(value)));
    }

    return false;
}


bool VenueSortFilterProxyModel::venuePropertyMatches(const QModelIndex &index) const
{
    for (int roleKey = 0; roleKey <= VenueModel::ChildChair - VenueModel::Wlan; roleKey++)
    {
        if (m_filterVenueProperty.testFlag(VenueSortFilterProxyModel::VenueProperty(keyToFlag(roleKey))))
        {
            const auto roleValue = index.data(roleKey + VenueModel::Wlan);
            if (roleValue.isValid() && roleValue.canConvert<int>() && roleValue.toInt() == 1)
            {
                continue;
            }
            else
            {
                return false;
            }
        }
    }

    return true;
}



