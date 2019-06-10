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

VenueSortFilterProxyModel::VenueVegCategoryFlags VenueSortFilterProxyModel::filterVegCategory() const
{
    return m_filterVegCategory;
}

VenueModel::VenueSubTypeFlags VenueSortFilterProxyModel::filterVenueSubType() const
{
    return m_filterVenueSubType;
}

VenueSortFilterProxyModel::VenuePropertyFlags VenueSortFilterProxyModel::filterVenueProperty() const
{
    return m_filterVenueProperty;
}

template <typename FilterFlags, typename SignalType>
void VenueSortFilterProxyModel::setFilterFlag(FilterFlags& filterFlagMask, const typename FilterFlags::enum_type flag, const bool on, SignalType filterChangedSignal)
{
    if (filterFlagMask.testFlag(flag) == on)
    {
        return;
    }

    if (on)
    {
        filterFlagMask |= flag;
    }
    else
    {
        filterFlagMask &= ~flag;
    }

    invalidateFilter();
    emit (this->*filterChangedSignal)();
}

void VenueSortFilterProxyModel::setVegCategoryFilterFlag(VenueVegCategoryFlag flag, bool on)
{
    setFilterFlag(m_filterVegCategory, flag, on, &VenueSortFilterProxyModel::filterVegCategoryChanged);
}

void VenueSortFilterProxyModel::setVenuePropertyFilterFlag(VenuePropertyFlag flag, bool on)
{
    setFilterFlag(m_filterVenueProperty, flag, on, &VenueSortFilterProxyModel::filterVenuePropertyChanged);
}

void VenueSortFilterProxyModel::setVenueSubTypeFilterFlag(int flag, bool on)
{
    setFilterFlag(m_filterVenueSubType, static_cast<VenueModel::VenueSubTypeFlag>(flag), on, &VenueSortFilterProxyModel::filterVenueSubTypeChanged);
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
    emit modelChanged();
}

void VenueSortFilterProxyModel::setSearchString(QString searchString)
{
    QString simplifiedSearchString = simplifySearchString(searchString);
    if (m_simplifiedSearchString == simplifiedSearchString)
    {
        return;
    }

    m_simplifiedSearchString.swap(simplifiedSearchString);
    invalidateFilter();
    emit searchStringChanged();
}

void VenueSortFilterProxyModel::setFilterVenueType(VenueModel::VenueTypeFlags filterVenueTypeFlags)
{
    if (m_filterVenueType == filterVenueTypeFlags)
    {
        return;
    }

    m_filterVenueType = filterVenueTypeFlags;
    invalidateFilter();
    emit filterVenueTypeChanged();
}

void VenueSortFilterProxyModel::setFilterFavorites(bool filterFavorites)
{
    if (m_filterFavorites == filterFavorites)
    {
        return;
    }

    m_filterFavorites = filterFavorites;
    invalidateFilter();
    emit filterFavoritesChanged();
}

void VenueSortFilterProxyModel::setFilterOpenNow(bool filterOpenNow)
{
    if (m_filterOpenNow == filterOpenNow)
    {
        return;
    }

    m_filterOpenNow = filterOpenNow;
    invalidateFilter();
    emit filterOpenNowChanged();
}

void VenueSortFilterProxyModel::setCurrentPosition(QGeoCoordinate position)
{
    if (m_currentPosition == position)
    {
        return;
    }

    m_currentPosition = position;
    reSort();
}


bool VenueSortFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (sourceModel() == nullptr)
    {
        return false;
    }

    auto index = sourceModel()->index( source_row, 0, source_parent );
    if (!index.isValid())
    {
        return false;
    }

    if (m_filterFavorites)
    {
        return favoriteStatusMatches(index)
           && (!m_filterOpenNow || openNow(index))
           && searchStringMatches(index);
    }
    else
    {
        const auto venueTypeRole = index.data(VenueModel::VenueModelRoles::VenueTypeRole);
        if (!(venueTypeRole.isValid() && venueTypeRole.canConvert<int>()))
        {
            return false;
        }

        const auto venueType = static_cast<VenueModel::VenueType>(venueTypeRole.toInt());

        return venueTypeMatches(venueType)
            && vegCategoryMatches(index)
            && venueSubTypeMatches(index)
            // Only Food venues are filtered for venue properties (as of now)
            && (venueType == VenueModel::Shop || venuePropertiesMatch(index))
            && (!m_filterOpenNow || openNow(index))
            // Filter search string last => slowest
            && searchStringMatches(index);
    }
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
    if (m_simplifiedSearchString.isEmpty())
    {
        return true;
    }

    auto valueRole = index.data( VenueModel::VenueModelRoles::SimplifiedSearchName );
    if (valueRole.isValid() && valueRole.canConvert<QString>())
    {
        auto const value = valueRole.toString();
        if (value.contains(m_simplifiedSearchString))
        {
            return true;
        }
    }

    valueRole = index.data( VenueModel::VenueModelRoles::SimplifiedSearchStreet);
    if (valueRole.isValid() && valueRole.canConvert<QString>())
    {
        auto const value = valueRole.toString();
        if (value.contains(m_simplifiedSearchString))
        {
            return true;
        }
    }

    valueRole = index.data( VenueModel::VenueModelRoles::SimplifiedSearchDescription);
    if (valueRole.isValid() && valueRole.canConvert<QString>())
    {
        auto const value = valueRole.toString();
        if (value.contains(m_simplifiedSearchString))
        {
            return true;
        }
    }

    valueRole = index.data( VenueModel::VenueModelRoles::SimplifiedSearchDescriptionEn);
    if (valueRole.isValid() && valueRole.canConvert<QString>())
    {
        auto const value = valueRole.toString();
        if (value.contains(m_simplifiedSearchString))
        {
            return true;
        }
    }

    valueRole = index.data( VenueModel::VenueModelRoles::SimplifiedSearchReview);
    if (valueRole.isValid() && valueRole.canConvert<QString>())
    {
        auto const value = valueRole.toString();
        if (value.contains(m_simplifiedSearchString))
        {
            return true;
        }
    }

    return false;
}

bool VenueSortFilterProxyModel::favoriteStatusMatches(const QModelIndex &index) const
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

bool VenueSortFilterProxyModel::openNow(const QModelIndex &index) const
{
    const auto valueRole = index.data( VenueModel::VenueModelRoles::Open);
    if (valueRole.isValid() && valueRole.canConvert<bool>())
    {
        return valueRole.toBool();
    }
    else
    {
        return false;
    }
}


bool VenueSortFilterProxyModel::venueTypeMatches(const VenueModel::VenueType& venueType) const
{
    return m_filterVenueType.testFlag(static_cast<VenueModel::VenueTypeFlag>(enumValueToFlag(venueType)));
}


bool VenueSortFilterProxyModel::venueSubTypeMatches(const QModelIndex &index) const
{

    const auto venueSubTypeRole = index.data(VenueModel::VenueModelRoles::VenueSubTypeRole);
    if (venueSubTypeRole.isValid() && venueSubTypeRole.canConvert<int>())
    {
        const auto venueSubTypeFlag = venueSubTypeRole.toInt();
        return m_filterVenueSubType & static_cast<typename VenueModel::VenueSubTypeFlags>(venueSubTypeFlag);
    }

    return false;
}

template <typename FilterFlags>
bool testCategoryFilter(const QModelIndex &index, VenueModel::VenueModelRoles role, const FilterFlags& filterFlags)
{
    const auto valueRole = index.data(role);
    if (valueRole.isValid() && valueRole.canConvert<int>())
    {
        const auto value = valueRole.toInt();
        return filterFlags.testFlag(static_cast<typename FilterFlags::enum_type>(enumValueToFlag(value)));
    }

    return false;
}


bool VenueSortFilterProxyModel::vegCategoryMatches(const QModelIndex &index) const
{
    return testCategoryFilter(index, VenueModel::VenueModelRoles::VegCategory, m_filterVegCategory);
}

bool VenueSortFilterProxyModel::venuePropertiesMatch(const QModelIndex &index) const
{
    for (int roleKey = VenueModel::FirstPropertyRole; roleKey <= VenueModel::LastPropertyRole; roleKey++)
    {
        if (m_filterVenueProperty.testFlag(VenuePropertyFlag(enumValueToFlag(roleKey, VenueModel::FirstPropertyRole))))
        {
            const auto roleValue = index.data(roleKey);
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



