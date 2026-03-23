#include "OSMProvider.h"

#include <QNetworkReply>
#include <QJsonDocument>
#include <QUrlQuery>

static const QString OVERPASS_URL = QStringLiteral("https://overpass-api.de/api/interpreter");

// Berlin metro bounding box (includes Potsdam, Ludwigsfelde, Bernau)
static const QString BERLIN_METRO_BBOX = QStringLiteral("52.25,12.85,52.75,13.85");

// VenueModel::VenueVegCategory values
static constexpr int VegCategory_Omnivorous = 1;
static constexpr int VegCategory_OmnivorousVeganLabeled = 2;
static constexpr int VegCategory_Vegetarian = 3;
static constexpr int VegCategory_Vegan = 5;

OSMProvider::OSMProvider(QObject *parent)
    : QObject(parent)
{
}

void OSMProvider::fetchMetroArea()
{
    const auto query = QStringLiteral(
        "[out:json][timeout:60];"
        "("
        "  node[\"diet:vegan\"~\"yes|only\"](%1);"
        "  node[\"diet:vegetarian\"~\"yes|only\"][\"diet:vegan\"!~\".\"](%1);"
        "  way[\"diet:vegan\"~\"yes|only\"](%1);"
        "  way[\"diet:vegetarian\"~\"yes|only\"][\"diet:vegan\"!~\".\"](%1);"
        ");"
        "out center body;"
    ).arg(BERLIN_METRO_BBOX);

    executeQuery(query);
}

void OSMProvider::fetchNearby(const QGeoCoordinate& center, int radiusMeters)
{
    const auto query = QStringLiteral(
        "[out:json][timeout:15];"
        "("
        "  nwr[\"diet:vegan\"~\"yes|only\"](around:%1,%2,%3);"
        "  nwr[\"diet:vegetarian\"~\"yes|only\"][\"diet:vegan\"!~\".\"](around:%1,%2,%3);"
        ");"
        "out center body;"
    ).arg(radiusMeters)
     .arg(center.latitude(), 0, 'f', 6)
     .arg(center.longitude(), 0, 'f', 6);

    executeQuery(query);
}

void OSMProvider::executeQuery(const QString& query)
{
    if (m_loading) return;

    m_loading = true;
    emit loadingChanged();

    QNetworkRequest request(OVERPASS_URL);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    request.setRawHeader("User-Agent", "BerlinVegan-App/3.7.0");

    QUrlQuery postData;
    postData.addQueryItem("data", query);

    auto* reply = m_networkManager.post(request, postData.toString(QUrl::FullyEncoded).toUtf8());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();

        if (reply->error() == QNetworkReply::NoError)
        {
            parseResponse(reply->readAll());
        }
        else
        {
            qWarning() << "Overpass query failed:" << reply->errorString();
            emit error(QStringLiteral("OSM query failed: ") + reply->errorString());
        }

        m_loading = false;
        emit loadingChanged();
    });
}

void OSMProvider::parseResponse(const QByteArray& data)
{
    const auto doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) {
        emit error(QStringLiteral("Invalid Overpass response"));
        return;
    }

    const auto elements = doc.object()["elements"].toArray();
    QJsonArray venues;

    for (const auto& element : elements)
    {
        const auto venue = osmElementToVenue(element.toObject());
        if (!venue.isEmpty())
            venues.append(venue);
    }

    qInfo() << "OSM: found" << venues.size() << "vegan/vegetarian venues";
    emit venuesReady(venues);
}

QJsonObject OSMProvider::osmElementToVenue(const QJsonObject& element) const
{
    const auto tags = element["tags"].toObject();
    const auto name = tags["name"].toString();

    if (name.isEmpty()) return {};

    // Get coordinates (nodes have lat/lon directly, ways/relations have center)
    double lat, lon;
    if (element.contains("center")) {
        lat = element["center"].toObject()["lat"].toDouble();
        lon = element["center"].toObject()["lon"].toDouble();
    } else {
        lat = element["lat"].toDouble();
        lon = element["lon"].toDouble();
    }

    QJsonObject venue;
    venue["id"] = QStringLiteral("osm_") + QString::number(element["id"].toInteger());
    venue["name"] = name;
    venue["latCoord"] = lat;
    venue["longCoord"] = lon;

    // Street address
    const auto street = tags["addr:street"].toString();
    const auto houseNumber = tags["addr:housenumber"].toString();
    venue["street"] = street.isEmpty() ? QString() : street + " " + houseNumber;

    // Contact
    venue["telephone"] = tags["phone"].toString();
    venue["website"] = tags["website"].toString();

    // Vegan category
    venue["vegan"] = mapDietTagToVegCategory(
        tags["diet:vegan"].toString(),
        tags["diet:vegetarian"].toString()
    );

    // Properties (-1 = unknown, 0 = no, 1 = yes)
    venue["organic"] = tags.contains("organic") ? (tags["organic"].toString() == "yes" ? 1 : 0) : -1;
    venue["handicappedAccessible"] = tags.contains("wheelchair") ? (tags["wheelchair"].toString() == "yes" ? 1 : 0) : -1;
    venue["wlan"] = tags["internet_access"].toString() == "wlan" ? 1 : -1;
    venue["dog"] = tags.contains("dog") ? (tags["dog"].toString() == "yes" ? 1 : 0) : -1;
    venue["childChair"] = tags.contains("highchair") ? (tags["highchair"].toString() == "yes" ? 1 : 0) : -1;
    venue["delivery"] = tags.contains("delivery") ? (tags["delivery"].toString() == "yes" ? 1 : 0) : -1;

    // Opening hours (raw OSM format)
    venue["openComment"] = tags["opening_hours"].toString();

    // Venue type and sub-type
    const auto amenity = tags["amenity"].toString();
    const auto shop = tags["shop"].toString();

    if (!shop.isEmpty()) {
        venue["venueType"] = 1; // Shop
        QJsonArray shopTags;
        if (shop == "supermarket") shopTags.append("supermarket");
        else if (shop == "clothes") shopTags.append("clothing");
        else if (shop == "cosmetics" || shop == "chemist") shopTags.append("toiletries");
        else shopTags.append("foods");
        venue["tags"] = shopTags;
    } else {
        venue["venueType"] = 0; // Gastro
        QJsonArray gastroTags;
        if (amenity == "restaurant") gastroTags.append("Restaurant");
        else if (amenity == "cafe") gastroTags.append("Cafe");
        else if (amenity == "fast_food") gastroTags.append("Imbiss");
        else if (amenity == "bar") gastroTags.append("Bar");
        else if (amenity == "ice_cream") gastroTags.append("Eiscafe");
        else gastroTags.append("Restaurant");
        venue["tags"] = gastroTags;
    }

    return venue;
}

int OSMProvider::mapDietTagToVegCategory(const QString& dietVegan, const QString& dietVegetarian) const
{
    if (dietVegan == "only") return VegCategory_Vegan;
    if (dietVegan == "yes") return VegCategory_OmnivorousVeganLabeled;
    if (dietVegetarian == "only") return VegCategory_Vegetarian;
    if (dietVegetarian == "yes") return VegCategory_OmnivorousVeganLabeled;
    return VegCategory_Omnivorous;
}
