#include "VenueModel.h"

#include "OpeningHoursAlgorithms.h"

#include <QtQml/qqml.h>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSValueIterator>

#include <QDateTime>

#include <QStandardItem>

VenueModel::VenueModel(QObject *parent) :
    QStandardItemModel(parent)
{

}

VenueModel::VenueSubTypeFlag subTypeStringToFlag(const QString name)
{
    static const auto subTypeStringLookup
    = QHash<QString, VenueModel::VenueSubTypeFlag>
    {
        // Gastro tags
        { QStringLiteral("Restaurant")  , VenueModel::RestaurantFlag    },
        { QStringLiteral("Imbiss")      , VenueModel::FastFoodFlag      },
        { QStringLiteral("Cafe")        , VenueModel::CafeFlag          },
        { QStringLiteral("Eiscafe")     , VenueModel::IceCreamFlag      },
        { QStringLiteral("Bar")         , VenueModel::BarFlag           },

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

            if (roleKey == VenueModelRoles::Created)
            {
                item->setData(value.toVariant(), VenueModelRoles::DateCreated);
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

