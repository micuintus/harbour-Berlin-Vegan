#include "VenueModel.h"

#include <QStandardItem>
#include <QtQml/qqml.h>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSValueIterator>


VenueModel::VenueModel(QObject *parent) :
    QStandardItemModel(parent)
{ }

VenueModel::VenueSubTypeFlag subTypeStringToFlag(const QString name)
{
    static const auto subTypeStringLookup
    = QHash<QString, VenueModel::VenueSubTypeFlag>
    {
        { "Restaurant" , VenueModel::RestaurantFlag },
        { "Imbiss"     , VenueModel::FastFoodFlag   },
        { "Cafe"       , VenueModel::CafeFlag       },
        { "Eiscafe"    , VenueModel::IceCreamFlag   }
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
            ret.setFlag(flag);
        }
    }

    return ret;
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
            auto const value = from.property(roleName);
            item->setData(value.toVariant(), roleKey);
        }
    }

    auto const venueSubType = extractVenueSubType(from);
    item->setData(QVariant::fromValue(static_cast<int>(venueSubType)), VenueModelRoles::VenueSubTypeRole);

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
        { VenueModelRoles::ID,            "id"          },
        { VenueModelRoles::Name,          "name"        },
        { VenueModelRoles::Favorite,      "favorite"    },
        { VenueModelRoles::Street,        "street"      },
        { VenueModelRoles::Description,   "comment"     },
        { VenueModelRoles::Website,       "website"     },
        { VenueModelRoles::Telephone,     "telephone"   },
        { VenueModelRoles::Pictures,      "pictures"    },

        // Coordinates
        { VenueModelRoles::LatCoord,      "latCoord"    },
        { VenueModelRoles::LongCoord,     "longCoord"   },

        // Properties
        { VenueModelRoles::Wlan,          "wlan" },
        { VenueModelRoles::VegCategory,   "vegan" },
        { VenueModelRoles::HandicappedAccessible,
                                          "handicappedAccessible" },
        { VenueModelRoles::HandicappedAccessibleWc,
                                          "handicappedAccessibleWc" },
        { VenueModelRoles::Catering,      "catering"     },
        { VenueModelRoles::Organic,       "organic"      },
        { VenueModelRoles::GlutenFree,    "glutenFree"   },
        { VenueModelRoles::Delivery,      "delivery"     },
        { VenueModelRoles::SeatsOutdoor,  "seatsOutdoor" },
        { VenueModelRoles::SeatsIndoor,   "seatsIndoor"  },
        { VenueModelRoles::Dog,           "dog"          },
        { VenueModelRoles::ChildChair,    "childChair"   },

        // OpeningHours
        { VenueModelRoles::OtMon,         "otMon"  },
        { VenueModelRoles::OtTue,         "otTue"  },
        { VenueModelRoles::OtWed,         "otWed"  },
        { VenueModelRoles::OtThu,         "otThu"  },
        { VenueModelRoles::OtFri,         "otFri"  },
        { VenueModelRoles::OtSat,         "otSat"  },
        { VenueModelRoles::OtSun,         "otSun"  }

    };

    return roles;
}

VenueModel::VenueTypeFlags VenueModel::loadedVenueType() const
{
    return m_loadedVenueType;
}

