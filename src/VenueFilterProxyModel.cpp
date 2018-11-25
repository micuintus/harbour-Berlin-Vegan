#include "VenueFilterProxyModel.h"

VenueFilterProxyModel::VenueFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
}



VenueFilterProxyModel::VenueVegCategoryFlags VenueFilterProxyModel::filterVegCategory() const
{
    return m_filterVegCategory;
}

VenueModel::VenueSubTypeFlags VenueFilterProxyModel::filterVenueSubType() const
{
    return m_filterVenueSubType;
}

VenueFilterProxyModel::VenuePropertyFlags VenueFilterProxyModel::filterVenueProperty() const
{
    return m_filterVenueProperty;
}

template <typename FilterFlags, typename SignalType>
void VenueFilterProxyModel::setFilterFlag(FilterFlags& filterFlagMask, const typename FilterFlags::enum_type flag, const bool on, SignalType filterChangedSignal)
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

void VenueFilterProxyModel::setVegCategoryFilterFlag(VenueVegCategoryFlag flag, bool on)
{
    setFilterFlag(m_filterVegCategory, flag, on, &VenueFilterProxyModel::filterVegCategoryChanged);
}

void VenueFilterProxyModel::setVenuePropertyFilterFlag(VenuePropertyFlag flag, bool on)
{
    setFilterFlag(m_filterVenueProperty, flag, on, &VenueFilterProxyModel::filterVenuePropertyChanged);
}

void VenueFilterProxyModel::setVenueSubTypeFilterFlag(int flag, bool on)
{
    setFilterFlag(m_filterVenueSubType, static_cast<VenueModel::VenueSubTypeFlag>(flag), on, &VenueFilterProxyModel::filterVenueSubTypeChanged);
}


void VenueFilterProxyModel::setSearchString(QString searchString)
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

void VenueFilterProxyModel::setFilterVenueType(VenueModel::VenueTypeFlags filterVenueTypeFlags)
{
    if (m_filterVenueType == filterVenueTypeFlags)
    {
        return;
    }

    m_filterVenueType = filterVenueTypeFlags;
    invalidateFilter();
    emit filterVenueTypeChanged();
}

void VenueFilterProxyModel::setFilterFavorites(bool filterFavorites)
{
    if (m_filterFavorites == filterFavorites)
    {
        return;
    }

    m_filterFavorites = filterFavorites;
    invalidateFilter();
    emit filterFavoritesChanged();
}

void VenueFilterProxyModel::setFilterOpenNow(bool filterOpenNow)
{
    if (m_filterOpenNow == filterOpenNow)
    {
        return;
    }

    m_filterOpenNow = filterOpenNow;
    invalidateFilter();
    emit filterOpenNowChanged();
}



bool VenueFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
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
            // Only Food venues are filtered for sub type and properties
            && (venueType == VenueModel::Shopping || (venueSubTypeMatches(index) && venuePropertiesMatch(index)))
            && (!m_filterOpenNow || openNow(index))
            // Filter search string last => slowest
            && searchStringMatches(index);
    }
}

bool VenueFilterProxyModel::searchStringMatches(const QModelIndex &index) const
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

    return false;
}

bool VenueFilterProxyModel::favoriteStatusMatches(const QModelIndex &index) const
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

bool VenueFilterProxyModel::openNow(const QModelIndex &index) const
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


bool VenueFilterProxyModel::venueTypeMatches(const VenueModel::VenueType& venueType) const
{
    return m_filterVenueType.testFlag(static_cast<VenueModel::VenueTypeFlag>(enumValueToFlag(venueType)));
}


bool VenueFilterProxyModel::venueSubTypeMatches(const QModelIndex &index) const
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


bool VenueFilterProxyModel::vegCategoryMatches(const QModelIndex &index) const
{
    return testCategoryFilter(index, VenueModel::VenueModelRoles::VegCategory, m_filterVegCategory);
}

bool VenueFilterProxyModel::venuePropertiesMatch(const QModelIndex &index) const
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



