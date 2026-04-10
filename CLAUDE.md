# Berlin-Vegan App - Development Guide

## Overview

Cross-platform mobile guide for discovering vegan/vegetarian venues in Berlin metro area.
~3000+ venues from OpenStreetMap + ~227 curated venues from berlin-vegan.de, with GPS sorting,
multi-dimensional filtering, opening hours intelligence, favorites, and map views.

## Platforms & Build Systems

| Platform | Toolkit | Distribution | Build System | Qt Version |
|----------|---------|-------------|-------------|------------|
| iOS | Felgo 4.3+ | App Store | CMake | Qt 6.8+ |
| Android (Play Store) | Felgo 4.3+ | Google Play | CMake | Qt 6.8+ |
| Android (FOSS) | Kirigami (KF6) | F-Droid | CMake | Qt 6.8+ |
| SailfishOS (native) | Sailfish Silica | Jolla Store | QMake | Qt 5.6 |
| SailfishOS (Kirigami) | Kirigami (KF6) | OpenRepos | CMake | Qt 6.8+ |
| Desktop (dev) | Felgo 4.3+ | — | CMake | Qt 6.8+ |
| Desktop (Linux) | Kirigami (KF6) | Flatpak/distro | CMake | Qt 6.8+ |

Platform selection at configure time via `BV_PLATFORM` (default: `felgo`):

## Build Commands

### Felgo (Desktop/iOS/Android)
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/path/to/felgo -DBV_PLATFORM=felgo -GNinja
ninja
```

### Kirigami (Desktop/Android — requires KF6 Kirigami)
```bash
mkdir -p build-kirigami && cd build-kirigami
cmake .. -DBV_PLATFORM=kirigami -GNinja
ninja
```

### Tests
```bash
ninja -C build tst_osm_opening_hours tst_opening_hours_algorithms tst_deduplication
build/tests/tst_osm_opening_hours        # 21 tests
build/tests/tst_opening_hours_algorithms  # 18 tests
build/tests/tst_deduplication             # 11 tests
```

## Project Structure

```
harbour-Berlin-Vegan/
├── src/                           # C++ backend
│   ├── main.cpp                   # Entry point (minimal, no type registration)
│   ├── VenueModel.h/cpp           # Data model (QStandardItemModel, QML_ELEMENT)
│   ├── VenueSortFilterProxyModel.h/cpp  # Filter/sort engine
│   ├── VenueHandle.h              # QML property proxy per venue
│   ├── OSMProvider.h/cpp          # Overpass API client (QML_SINGLETON)
│   ├── OsmOpeningHoursParser.h/cpp # OSM opening_hours format parser
│   ├── VenueDataLoader.h/cpp      # berlin-vegan.de JSON loader (QML_SINGLETON)
│   ├── NominatimService.h/cpp      # Nominatim geocoding + address search (QML_SINGLETON)
│   ├── FavoritesManager.h/cpp     # Favorites persistence (QML_SINGLETON)
│   ├── OpeningHoursAlgorithms.h/cpp # Opening hours parsing + Berlin holidays
│   └── TruncationMode.h           # Text truncation enum (QML_UNCREATABLE)
│
├── qml/                           # QML pages and venue components
│   ├── harbour-berlin-vegan.qml   # Root ApplicationWindow
│   ├── pages/                     # VenueList, VenueDescription, Filter, Map, About
│   ├── components/                # Venue business components (VenueListItem, etc.)
│   └── cover/                     # Sailfish cover page
│
├── components-platform/           # Platform abstraction (BV_PLATFORM selects one)
│   ├── felgo/qml/                 # Felgo implementations (33 components)
│   ├── kirigami/qml/              # Kirigami/KF6 implementations (33 components)
│   └── sailfish/                  # Sailfish Silica implementations (qmldir)
│
├── components-ui/qml/             # Reusable UI (SwipeView, CollapsibleItem, etc.)
├── tests/                         # Qt Test unit tests (50 tests)
├── translations/                  # i18n (.ts): de, en, nl
├── macos/                         # macOS Info.plist (location permissions)
├── android/                       # AndroidManifest.xml
├── ios/                           # Info.plist, assets
└── rpm/                           # SailfishOS RPM packaging
```

## Architecture

### Data Flow
```
berlin-vegan.de JSON → VenueDataLoader (C++) → VenueModel.importFromJson()
OSM Overpass API → OSMProvider (C++) → VenueModel.importOSMVenues() [with dedup]
  → VenueSortFilterProxyModel (C++) → VenueHandle (C++) → QML Pages
```

### Data Sources
- **berlin-vegan.de**: ~227 curated venues, rich data (photos, bilingual descriptions)
- **OpenStreetMap**: ~3000+ venues via Overpass API, Berlin metro bbox preload with local cache

### C++ Core (all use QML_ELEMENT)
- **VenueModel**: QStandardItemModel with macro-generated roles, OSM deduplication
- **VenueSortFilterProxyModel**: OR/AND filters, distance sort, deferred invalidation
- **OSMProvider**: Multi-endpoint Overpass with cache-first loading (QML_SINGLETON)
- **OsmOpeningHoursParser**: Parses "Mo-Fr 09:00-18:00" format (~90% coverage)
- **NominatimService**: Nominatim address search + geocoding, Berlin-scoped (QML_SINGLETON)
- **FavoritesManager**: QSettings-based persistence (QML_SINGLETON)
- **VenueDataLoader**: Network + cache + bundled resource fallback (QML_SINGLETON)

### Platform Abstraction (3 modules)
- `harbour.berlin.vegan` - App module (C++ types + pages + venue components)
- `BerlinVegan.components.platform` - Platform wrappers (Felgo/Kirigami/Sailfish)
- `BerlinVegan.components.ui` - Reusable UI components

### Qt6 Patterns
- `QML_ELEMENT` / `QML_SINGLETON` / `QML_UNCREATABLE` (no qmlRegisterType)
- `qt_add_qml_module` with `NO_RESOURCE_TARGET_PATH` (Felgo requirement)
- `qt_add_resources` (no resources.qrc)
- `qt_add_translations` with `LRELEASE_OPTIONS -idbased`
- `qt_standard_project_setup` with I18N configuration

## Code Style

- **C++**: 4 spaces, `#pragma once`, PascalCase classes, camelCase methods, `m_` member prefix
- **QML**: 4 spaces, bare imports (no version numbers), BVApp alias for platform/ui
- **Translations**: `qsTrId("id-descriptive-name")` with `//%` source comments
- **Commit**: author `micu <micuintus@gmx.de>`, no Co-Authored-By
