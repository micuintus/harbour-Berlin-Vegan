#include "VenueModel.h"

#include "OpeningHoursAlgorithms.h"
#include "OsmOpeningHoursParser.h"

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

QJSValue removeSoftHyphon(const QJSValue& stringJS)
{
    if (!stringJS.isString())
    {
        // We don't perform any proper type checking
        // for any of the values anyhow. It's JSON, after all...
        return stringJS;
    }

    QString reviewString = stringJS.toString();
    QString removeSoft = reviewString.remove("&shy;");
    return removeSoft;
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
                value = removeSoftHyphon(value);
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
            venueItem->setData(QStringLiteral("bv"), VenueModelRoles::DataSource);
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

void VenueModel::importOSMVenues(const QJsonArray& venues)
{
    auto root = this->invisibleRootItem();
    int addedCount = 0;
    int dupCount = 0;
    int noNameCount = 0;

    for (const auto& venueValue : venues)
    {
        const auto venue = venueValue.toObject();
        if (venue["name"].toString().isEmpty()) {
            noNameCount++;
            continue;
        }

        if (isDuplicate(venue)) {
            dupCount++;
            continue;
        }

        auto item = osmVenueToItem(venue);
        root->appendRow(item);
        addedCount++;
    }

    qInfo() << "OSM import:" << addedCount << "added,"
            << dupCount << "duplicates removed,"
            << noNameCount << "unnamed skipped";

    if (addedCount > 0)
    {
        m_loadedVenueType |= GastroFlag | ShopFlag;
        emit loadedVenueTypeChanged();
    }

    emit osmVenuesLoaded(addedCount);
}

QStandardItem* VenueModel::osmVenueToItem(const QJsonObject& venue)
{
    auto item = new QStandardItem;

    item->setData(venue["id"].toString(), VenueModelRoles::ID);
    item->setData(venue["name"].toString().simplified(), VenueModelRoles::Name);
    item->setData(simplifySearchString(venue["name"].toString()), VenueModelRoles::SimplifiedSearchName);
    item->setData(venue["street"].toString(), VenueModelRoles::Street);
    item->setData(simplifySearchString(venue["street"].toString()), VenueModelRoles::SimplifiedSearchStreet);
    item->setData(venue["latCoord"].toDouble(), VenueModelRoles::LatCoord);
    item->setData(venue["longCoord"].toDouble(), VenueModelRoles::LongCoord);
    item->setData(venue["vegan"].toInt(), VenueModelRoles::VegCategory);
    item->setData(venue["telephone"].toString(), VenueModelRoles::Telephone);
    item->setData(venue["website"].toString(), VenueModelRoles::Website);
    item->setData(venue["openComment"].toString(), VenueModelRoles::OpenComment);
    item->setData(QStringLiteral("osm"), VenueModelRoles::DataSource);

    // Properties (-1 = unknown, 0 = no, 1 = yes)
    item->setData(venue["organic"].toInt(-1), VenueModelRoles::Organic);
    item->setData(venue["handicappedAccessible"].toInt(-1), VenueModelRoles::HandicappedAccessible);
    item->setData(venue["delivery"].toInt(-1), VenueModelRoles::Delivery);
    item->setData(venue["wlan"].toInt(-1), VenueModelRoles::Wlan);
    item->setData(venue["dog"].toInt(-1), VenueModelRoles::Dog);
    item->setData(venue["childChair"].toInt(-1), VenueModelRoles::ChildChair);

    // Venue type
    const int venueType = venue["venueType"].toInt(0);
    item->setData(venueType, VenueModelRoles::VenueTypeRole);

    // Sub-type from tags array
    const auto tags = venue["tags"].toArray();
    VenueSubTypeFlags subTypeFlags;
    for (const auto& tag : tags)
    {
        const auto flag = subTypeStringToFlag(tag.toString());
        subTypeFlags |= flag;
    }
    item->setData(QVariant::fromValue(static_cast<int>(subTypeFlags)), VenueModelRoles::VenueSubTypeRole);

    // Parse OSM opening_hours into per-day format for "open now" filtering
    const auto openingHoursRaw = venue["openComment"].toString();
    const auto oh = OsmOpeningHoursParser::parse(openingHoursRaw);
    if (oh.parsed)
    {
        static const char* dayTrIds[] = {
            "id-monday", "id-tuesday", "id-wednesday", "id-thursday",
            "id-friday", "id-saturday", "id-sunday"
        };

        QVariantList openingHours;
        for (int i = 0; i < 7; ++i)
        {
            const auto hours = oh.days[i].isEmpty() ? qtTrId("id-closed") : oh.days[i];
            openingHours.append(QVariantMap{
                {"day", qtTrId(dayTrIds[i])},
                {"hours", hours}
            });
        }

        item->setData(openingHours, VenueModelRoles::OpeningHours);

        auto const openingMinutes = extractOpeningMinutes(openingHours);
        item->setData(openingMinutes, VenueModelRoles::OpeningMinutes);
    }

    return item;
}

bool VenueModel::isDuplicate(const QJsonObject& osmVenue) const
{
    const double osmLat = osmVenue["latCoord"].toDouble();
    const double osmLon = osmVenue["longCoord"].toDouble();
    const auto osmName = simplifySearchString(osmVenue["name"].toString());

    for (int row = 0; row < rowCount(); ++row)
    {
        const auto idx = index(row, 0);
        const auto existingSource = idx.data(VenueModelRoles::DataSource).toString();

        // Only deduplicate against berlin-vegan.de venues
        if (existingSource == "osm")
            continue;

        const double lat = idx.data(VenueModelRoles::LatCoord).toDouble();
        const double lon = idx.data(VenueModelRoles::LongCoord).toDouble();

        const double dlat = qAbs(osmLat - lat);
        const double dlon = qAbs(osmLon - lon);

        // Very close (~30m): same venue regardless of name differences
        if (dlat < 0.0003 && dlon < 0.0004)
            return true;

        // Within ~200m: check name similarity
        if (dlat > 0.002 || dlon > 0.003)
            continue;

        const auto existingName = idx.data(VenueModelRoles::SimplifiedSearchName).toString();

        // Substring match
        if (osmName.contains(existingName) || existingName.contains(osmName))
            return true;

        // Prefix match (first 4 chars after normalization)
        if (osmName.length() >= 4 && existingName.length() >= 4
            && osmName.left(4) == existingName.left(4))
            return true;

        // Word-by-word: if first word matches
        const auto osmFirst = osmName.split(' ').first();
        const auto bvFirst = existingName.split(' ').first();
        if (osmFirst.length() >= 3 && osmFirst == bvFirst)
            return true;
    }

    return false;
}

VenueModel::VenueTypeFlags VenueModel::loadedVenueType() const
{
    return m_loadedVenueType;
}

