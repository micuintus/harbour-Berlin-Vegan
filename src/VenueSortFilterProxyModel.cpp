#include "VenueSortFilterProxyModel.h"
#include "OpeningHoursAlgorithms.h"

#include <QDate>

namespace detail {

QVariant openingMinutesForDay(const QModelIndex& index, int currentDayIndex)
{
    if (currentDayIndex < MONDAY_INDEX || currentDayIndex > SUNDAY_INDEX)
    {
        return QVariant::Invalid;
    }

    const auto openingMinutesVar = index.data(VenueModel::OpeningMinutes);
    if (!openingMinutesVar.isValid() || !openingMinutesVar.canConvert(QMetaType::QVariantList))
    {
        return QVariant::Invalid;
    }

    auto const openingMinutes = openingMinutesVar.toList();
    return openingMinutes[currentDayIndex];
}

bool isOpenAt(const QModelIndex& index, int dayIndex, int minute)
{
    const auto openingMinutes = openingMinutesForDay(index, dayIndex);
    if (!openingMinutes.isValid() || !openingMinutes.canConvert(QMetaType::QVariantMap))
    {
        return false;
    }

    return isInRange(openingMinutes.toMap(), minute);
}

bool isOpenAt(const QModelIndex& index, QDateTime dateTime)
{
    int dayIndex, minute;
    std::tie(dayIndex, minute) = extractDayIndexAndMinute(dateTime);
    return isOpenAt(index, dayIndex, minute);
}

bool closesSoon(const QModelIndex& index, int currentDayIndex, int currentMinute)
{
    const auto openingMinutes = openingMinutesForDay(index, currentDayIndex);
    if (!openingMinutes.isValid() || !openingMinutes.canConvert(QMetaType::QVariantMap))
    {
        return false;
    }

    // ClosesSoon holds true if venue is NOT open in half an hour from now
    return !isInRange(openingMinutes.toMap(), currentMinute + MINUTES_CLOSES_SOON);
}

bool hasReview(const QModelIndex& index)
{
    const auto valueRole = index.data(VenueModel::VenueModelRoles::Review);
    return valueRole.isValid() && valueRole.canConvert<QString>();
}

bool dateTodayInNewWindow(QDate dateCreated, QDate dateToday, int monthNew)
{
    //  dateCreated          dateCreatedPlusMonthNew       dateToday
    //  |                    |                             |
    //  *  --- monthNew ---  *                             *
    const QDate createdPlusMonthNew = dateCreated.addMonths(monthNew);
    return dateToday <= createdPlusMonthNew;
}

bool isNew(const QModelIndex& index, QDate dateToday, int monthNew)
{
    const auto dateCreatedVar = index.data(VenueModel::DateCreated);
    if (!dateCreatedVar.isValid() || !dateCreatedVar.canConvert(QMetaType::QDate))
    {
        return false;
    }

    return dateTodayInNewWindow(dateCreatedVar.toDate(), dateToday, monthNew);
}

}

VenueSortFilterProxyModel::VenueSortFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    sort(0);

    connect(this, &QAbstractItemModel::rowsRemoved, this, &VenueSortFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::rowsInserted, this, &VenueSortFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &VenueSortFilterProxyModel::countChanged);


    connect(&m_openStateUpdateTimer, &QTimer::timeout, this, &VenueSortFilterProxyModel::updateOpenState);
    m_openStateUpdateTimer.start(MICROSECONDS_PER_SECOND * SECONDS_PER_MINUTE/2);
    updateOpenState();
}

VenueModel* VenueSortFilterProxyModel::model() const
{
    return qobject_cast<VenueModel*>(sourceModel());
}

int VenueSortFilterProxyModel::count() const
{
    return rowCount();
}

VenueHandle* VenueSortFilterProxyModel::item(int row) const
{
    const auto model = this->model();
    if (!model)
    {
        return nullptr;
    }

    QModelIndex m = index(row, 0);

    return new VenueHandle(QPersistentModelIndex(m));
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

VenueSortFilterProxyModel::GastroPropertyFlags VenueSortFilterProxyModel::filterGastroProperty() const
{
    return m_filterGastroProperty;
}

QDate VenueSortFilterProxyModel::customOpenDate() const
{
    return m_customOpenDateTime.date();
}

QTime VenueSortFilterProxyModel::customOpenTime() const
{
    return m_customOpenDateTime.time();
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

void VenueSortFilterProxyModel::setGastroPropertyFilterFlag(VenueSortFilterProxyModel::GastroPropertyFlag flag, bool on)
{
    setFilterFlag(m_filterGastroProperty, flag, on, &VenueSortFilterProxyModel::filterGastroPropertyChanged);
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

    if (m_filterOpenNow && m_filterCustomOpen)
    {
        m_filterCustomOpen = false;
    }

    invalidateFilter();
    emit filterOpenChanged();
}

void VenueSortFilterProxyModel::setfilterCustomOpen(bool filterCustomOpen)
{
    if (m_filterCustomOpen == filterCustomOpen)
    {
        return;
    }

    m_filterCustomOpen = filterCustomOpen;

    if (m_filterCustomOpen && m_filterOpenNow)
    {
        m_filterOpenNow = false;
    }

    invalidateFilter();
    emit filterOpenChanged();
}

void VenueSortFilterProxyModel::setCustomOpenDate(QDate customOpenDate)
{
    if (m_customOpenDateTime.date() == customOpenDate)
    {
        return;
    }

    m_customOpenDateTime.setDate(customOpenDate);
    invalidateFilter();
    emit customOpenDateChanged();
}

void VenueSortFilterProxyModel::setCustomOpenTime(QTime customOpenTime)
{
    if (m_customOpenDateTime.time() == customOpenTime)
    {
        return;
    }

    m_customOpenDateTime.setTime(customOpenTime);
    invalidateFilter();
    emit customOpenTimeChanged();
}

void VenueSortFilterProxyModel::setFilterWithReview(bool filterWithReview)
{
    if (m_filterWithReview == filterWithReview)
    {
        return;
    }

    m_filterWithReview = filterWithReview;
    invalidateFilter();
    emit filterWithReviewChanged();
}

void VenueSortFilterProxyModel::setFilterNew(bool filterNew)
{
    if (m_filterNew == filterNew)
    {
        return;
    }

    m_filterNew = filterNew;
    invalidateFilter();
    emit filterNewChanged();
}

void VenueSortFilterProxyModel::setMonthNew(int monthNew)
{
    if (m_monthNew == monthNew)
    {
        return;
    }

    m_monthNew = monthNew;
    invalidateFilter();
    emit dataChanged(index(0, 0), index(rowCount() - 1, 0), { VenueModel::VenueModelRoles::IsNew});
    emit monthNewChanged();
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
        return favoriteStatusMatches(index) && searchStringMatches(index);
    }
    else
    {
        bool venueTypeIsMatching;
        VenueModel::VenueType venueType;
        std::tie(venueTypeIsMatching, venueType) = venueTypeMatches(index);
        const bool venueIsShop = venueType == VenueModel::VenueType::Shop;
        return venueTypeIsMatching
            && (venueIsShop || !m_filterWithReview || detail::hasReview(index))
            && (venueIsShop || !m_filterNew        || detail::isNew(index, QDate::currentDate(), m_monthNew))
            && vegCategoryMatches(index)
            && venueSubTypeMatches(index)
            && venuePropertiesMatch(index)
            && (venueIsShop || gastroPropertiesMatch(index))
            && (!m_filterOpenNow    || detail::isOpenAt(index, m_currentDayIndex, m_currentMinute))
            && (!m_filterCustomOpen || detail::isOpenAt(index, m_customOpenDateTime))
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

void VenueSortFilterProxyModel::updateOpenState()
{
    const auto currentDateTime = QDateTime::currentDateTime();
    std::tie(m_currentDayIndex, m_currentMinute) = extractDayIndexAndMinute(currentDateTime);
    emit dataChanged(index(0, 0), index(rowCount() - 1, 0), { VenueModel::VenueModelRoles::Open,
                                                              VenueModel::VenueModelRoles::ClosesSoon,
                                                              VenueModel::VenueModelRoles::CondensedOpeningHours });
}


QVariant VenueSortFilterProxyModel::data(const QModelIndex &index, int role) const
{
    switch(role)
    {
    case VenueModel::VenueModelRoles::Open:
    {
        return detail::isOpenAt(mapToSource(index), m_currentDayIndex, m_currentMinute);
    }
    case VenueModel::VenueModelRoles::ClosesSoon:
    {
        return detail::closesSoon(mapToSource(index), m_currentDayIndex, m_currentMinute);
    }
    case VenueModel::VenueModelRoles::IsNew:
    {
        return detail::isNew(mapToSource(index), QDate::currentDate(), m_monthNew);
    }
    case VenueModel::VenueModelRoles::CondensedOpeningHours:
    {
        const auto openingHoursVar = sourceData(index, VenueModel::OpeningHours);
        if (!openingHoursVar.isValid())
        {
            return QVariant::Invalid;
        }
        return condenseOpeningHours(openingHoursVar.toList(), m_currentDayIndex);
    }
    }

    return QSortFilterProxyModel::data(index, role);
}

QVariant VenueSortFilterProxyModel::sourceData(const QModelIndex &index, int role) const
{
    const auto sourceIndex = mapToSource(index);
    return model()->data(sourceIndex, role);
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

std::pair<bool, VenueModel::VenueType>
VenueSortFilterProxyModel::venueTypeMatches(const QModelIndex &index) const
{
    const auto venueTypeRole = index.data(VenueModel::VenueModelRoles::VenueTypeRole);
    if (!(venueTypeRole.isValid() && venueTypeRole.canConvert<int>()))
    {
        return { false, {} };
    }

    const auto venueType = static_cast<VenueModel::VenueType>(venueTypeRole.toInt());
    const bool match     = m_filterVenueType.testFlag(static_cast<VenueModel::VenueTypeFlag>(enumValueToFlag(venueType)));
    return { match, venueType };
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

template <typename FilterFlags>
bool testRolePropertyMatch(const QModelIndex &index,
                           FilterFlags flags,
                           VenueModel::VenueModelRoles firstPropertyRole,
                           VenueModel::VenueModelRoles lastPropertyRole)
{
    for (int roleKey = firstPropertyRole; roleKey <= lastPropertyRole; roleKey++)
    {
        if (flags.testFlag(static_cast<typename FilterFlags::enum_type>(enumValueToFlag(roleKey, firstPropertyRole))))
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

bool VenueSortFilterProxyModel::venuePropertiesMatch(const QModelIndex &index) const
{
    return testRolePropertyMatch(index,
                                 m_filterVenueProperty,
                                 VenueModel::FirstVenuePropertyRole,
                                 VenueModel::LastVenuePropertyRole);
}


bool VenueSortFilterProxyModel::gastroPropertiesMatch(const QModelIndex &index) const
{
    return testRolePropertyMatch(index,
                                 m_filterGastroProperty,
                                 VenueModel::FirstGastroPropertyRole,
                                 VenueModel::LastGastroPropertyRole);
}

