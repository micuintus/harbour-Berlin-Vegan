#include "VenueModel.h"

#include "OpeningHoursAlgorithms.h"

#include <QtQml/qqml.h>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSValueIterator>

#include <QDateTime>

#include <QStandardItem>

VenueModel::VenueModel(QObject *parent) :
    QStandardItemModel(parent) ,
    m_openStateUpdateTimer(this)
{
    updateOpenState();

    connect(&m_openStateUpdateTimer, &QTimer::timeout, this, &VenueModel::updateOpenState);
    m_openStateUpdateTimer.start(MICROSECONDS_PER_SECOND * SECONDS_PER_MINUTE/2);
}

VenueModel::VenueSubTypeFlag subTypeStringToFlag(const QString name)
{
    static const auto subTypeStringLookup
    = QHash<QString, VenueModel::VenueSubTypeFlag>
    {
        // Gastro tags
        { "Restaurant"  , VenueModel::RestaurantFlag    },
        { "Imbiss"      , VenueModel::FastFoodFlag      },
        { "Cafe"        , VenueModel::CafeFlag          },
        { "Eiscafe"     , VenueModel::IceCreamFlag      },
        { "Bar"         , VenueModel::BarFlag           },

        // Shop tags
        { "foods"       , VenueModel::FoodsFlag         },
        { "clothing"    , VenueModel::ClothingFlag      },
        { "toiletries"  , VenueModel::ToiletriesFlag    },
        { "supermarket" , VenueModel::SupermarketFlag   },
        { "hairdressers", VenueModel::HairdressersFlag  },
        { "sports"      , VenueModel::SportsFlag        },
        { "tatoostudio" , VenueModel::TattoostudioFlag  },
        { "accomodation", VenueModel::AccommodationFlag }
    };

    auto const it = subTypeStringLookup.find(name);
    if (it != subTypeStringLookup.end())
    {
        return *it;
    }
    else
    {
        return VenueModel::NoneFlag;
    }
}

VenueModel::VenueSubTypeFlags extractVenueSubType(const QJSValue& from)
{
    VenueModel::VenueSubTypeFlags ret;
    if (!from.hasProperty("tags"))
    {
        return ret;
    }

    auto const tagsProperty = from.property("tags");
    if (!tagsProperty.isArray())
    {
        return ret;
    }

    for (auto const& tagVariant : tagsProperty.toVariant().toList())
    {
        if (tagVariant.canConvert<QString>())
        {
            auto const flag = subTypeStringToFlag(tagVariant.toString());
            ret |= flag;
        }
    }

    return ret;
}

QVariant extractSimplifiedSearchName(const QJSValue& stringJS)
{
    if (!stringJS.isString())
    {
        // We don't perform any proper type checking
        // for any of the values anyhow. It's JSON, after all...
        return stringJS.toVariant();
    }

    return simplifySearchString(stringJS.toString());
}

QJSValue stripWhiteSpaces(const QJSValue& stringJS)
{
    if (!stringJS.isString())
    {
        // We don't perform any proper type checking
        // for any of the values anyhow. It's JSON, after all...
        return stringJS;
    }

    return stringJS.toString().simplified();
}

QStandardItem* VenueModel::jsonItem2QStandardItem(const QJSValue& from)
{
    auto item = new QStandardItem;
    auto roleNames = this->roleNames();
    for (auto roleKey : roleNames.keys())
    {
        auto roleName = QString(roleNames[roleKey]);
        if (from.hasProperty(roleName))
        {
            auto value = from.property(roleName);
            if (   roleKey == VenueModelRoles::Name
                || roleKey == VenueModelRoles::Street)
            {
                value = stripWhiteSpaces(value);
            }

            if (roleKey == VenueModelRoles::Name)
            {
                auto const simplifiedSearchName = extractSimplifiedSearchName(value);
                item->setData(simplifiedSearchName, VenueModelRoles::SimplifiedSearchName);
            }

            if (roleKey == VenueModelRoles::Street)
            {
                auto const simplifiedSearchName = extractSimplifiedSearchName(value);
                item->setData(simplifiedSearchName, VenueModelRoles::SimplifiedSearchStreet);
            }

            if (roleKey == VenueModelRoles::Description)
            {
                auto const simplifiedSearchName = extractSimplifiedSearchName(value);
                item->setData(simplifiedSearchName, VenueModelRoles::SimplifiedSearchDescription);
            }

            if (roleKey == VenueModelRoles::DescriptionEn)
            {
                auto const simplifiedSearchName = extractSimplifiedSearchName(value);
                item->setData(simplifiedSearchName, VenueModelRoles::SimplifiedSearchDescriptionEn);
            }

            if (roleKey == VenueModelRoles::Review)
            {
                auto const simplifiedSearchName = extractSimplifiedSearchName(value);
                item->setData(simplifiedSearchName, VenueModelRoles::SimplifiedSearchReview);
            }
            item->setData(value.toVariant(), roleKey);
        }
    }

    auto const venueSubType = extractVenueSubType(from);
    item->setData(QVariant::fromValue(static_cast<int>(venueSubType)), VenueModelRoles::VenueSubTypeRole);

    extractAndProcessOpenHoursData(*item, from);

    return item;
}


void VenueModel::importFromJson(const QJSValue &item, VenueType venueType)
{
    if (item.isArray()) {
        auto root = this->invisibleRootItem();
        QJSValueIterator array(item);

        while (array.next()) {
            if (!array.hasNext())
                break; // last value in array is an int with the length

            auto venueItem = jsonItem2QStandardItem(array.value());
            venueItem->setData(venueType, VenueModelRoles::VenueTypeRole);
            root->appendRow(venueItem);
        }
    }

    m_loadedVenueType |= VenueTypeFlag(enumValueToFlag(venueType));
    emit loadedVenueTypeChanged();
}

void VenueModel::setFavorite(const QString &id, bool favorite)
{
    auto const index = indexFromID(id);
    if (index.isValid())
    {
        setData(index, favorite, VenueModelRoles::Favorite);
    }
}

QModelIndex VenueModel::indexFromID(const QString& id) const
{
    auto const index = match(this->index(0,0), VenueModelRoles::ID, id, 1, Qt::MatchExactly);
    if (index.size() == 1)
    {
        return index[0];
    }
    else return QModelIndex();
}

QHash<int, QByteArray> VenueModel::roleNames() const
{
    static const auto roles =
    QHash<int, QByteArray>
    {
#define ROLE_NAME_ID_PAIR(NAME, ID) \
        { VenueModelRoles::ID, #NAME},
        ROLE_NAME_ID_PAIRS
#undef ROLE_NAME_ID_PAIR
    };

    return roles;
}

VenueModel::VenueTypeFlags VenueModel::loadedVenueType() const
{
    return m_loadedVenueType;
}

void VenueModel::updateOpenState()
{
    const auto currentDateTime = QDateTime::currentDateTime();
    std::tie(m_currendDayIndex, m_currentMinute) = extractDayIndexAndMinute(currentDateTime);
    emit dataChanged(index(0, 0), index(rowCount() - 1, 0), { VenueModelRoles::Open,
                                                              VenueModelRoles::ClosesSoon,
                                                              VenueModelRoles::CondensedOpeningHours });
}

QVariant VenueModel::data(const QModelIndex &index, int role) const
{
    switch(role)
    {
        case VenueModelRoles::Open:
        case VenueModelRoles::ClosesSoon:
        {
            const auto openingMinutesVar = QStandardItemModel::data(index, VenueModel::OpeningMinutes);
            if (m_currendDayIndex < 0 || !openingMinutesVar.isValid())
            {
                return QVariant::fromValue(false);
            }

            auto const openingMinutes = openingMinutesVar.toList();

            switch(role)
            {
            case VenueModelRoles::Open:
                return isInRange(openingMinutes[m_currendDayIndex].toMap(), m_currentMinute);
            case VenueModelRoles::ClosesSoon:
                // ClosesSoon holds true if venue is NOT open in half an hour from now
                return !isInRange(openingMinutes[m_currendDayIndex].toMap(), m_currentMinute + MINUTES_CLOSES_SOON);
            }
        }
        break;
        case VenueModelRoles::CondensedOpeningHours:
        {
            const auto openingHoursVar = QStandardItemModel::data(index, VenueModel::OpeningHours);
            if (!openingHoursVar.isValid())
            {
                return QVariant::Invalid;
            }

            return condenseOpeningHours(openingHoursVar.toList(), m_currendDayIndex);
        }
    }

    return QStandardItemModel::data(index, role);
}
