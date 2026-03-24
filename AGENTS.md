# Agent Guidelines for Berlin-Vegan

## Project Overview

Berlin-Vegan is a Qt6/QML cross-platform mobile app for iOS, Android, and SailfishOS. It displays ~3000+ vegan/vegetarian venues in Berlin from OpenStreetMap + ~227 curated venues from berlin-vegan.de.

- **Platforms**: iOS/Android/Desktop (Felgo 4.3+), SailfishOS (Sailfish Silica)
- **Languages**: C++17, QML (bare imports, no version numbers)
- **Build System**: CMake (primary), QMake (Sailfish only)
- **License**: GPL v2 or later

## Build Commands

### Felgo (Desktop/iOS/Android)
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/path/to/felgo -GNinja
ninja
```

### Tests (68 tests across 5 suites)
```bash
ninja -C build tst_osm_opening_hours tst_opening_hours_algorithms tst_deduplication tst_osm_provider tst_favorites
```

## Code Style

### C++ Style
- **Standard**: C++17
- **Indentation**: 4 spaces (no tabs)
- **Headers**: `#pragma once`
- **Type registration**: `QML_ELEMENT` / `QML_SINGLETON` / `QML_UNCREATABLE` (no qmlRegisterType)

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `VenueModel`, `OSMProvider` |
| Methods | camelCase | `importOSMVenues()`, `fetchMetroArea()` |
| Members | m_ prefix | `m_loadedVenueType` |
| Constants | constexpr + UPPER_CASE | `constexpr int DAYS_PER_WEEK = 7;` |

### QML Style
- **Imports**: Bare (no version numbers): `import QtQuick`, `import QtPositioning`
- **Module alias**: `import BerlinVegan.components.platform 1.0 as BVApp`
- **Translations**: `qsTrId("id-descriptive-name")` with `//%` source comments

```qml
import QtQuick
import QtPositioning
import harbour.berlin.vegan 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.ui 1.0 as BVApp
```

## Project Structure

```
harbour-Berlin-Vegan/
├── src/                             # C++ backend (QML_ELEMENT types)
├── qml/                             # Shared QML pages
│   ├── pages/                       # VenueList, VenueDescription, Filter, Map, About
│   ├── components/                  # Venue business components
│   └── cover/                       # Sailfish cover page
├── components-platform/
│   ├── felgo/qml/                   # Felgo platform wrappers (33 components)
│   └── sailfish/                    # Sailfish platform wrappers (qmldir)
├── components-ui/qml/               # Reusable UI (SwipeView, CollapsibleItem, etc.)
├── tests/                           # 68 Qt Test unit tests (5 suites)
├── translations/                    # .ts files: de, en, nl (compiled at build time)
├── macos/                           # macOS Info.plist
├── android/                         # AndroidManifest.xml
├── ios/                             # Info.plist, assets
└── rpm/                             # SailfishOS RPM packaging
```

## Architecture

### 3-Module Structure
- `harbour.berlin.vegan` — App module (C++ types + pages + venue components)
- `BerlinVegan.components.platform` — Platform wrappers (Felgo OR Sailfish)
- `BerlinVegan.components.ui` — Reusable UI components

### Data Flow
```
berlin-vegan.de JSON → VenueDataLoader → VenueModel.importFromJson()
OSM Overpass API → OSMProvider → VenueModel.importOSMVenues() [dedup]
Missing streets → ReverseGeocoder → Nominatim API [background, cached]
  → VenueSortFilterProxyModel → VenueHandle → QML Pages
```

### C++ Singletons (QML_SINGLETON)
- **OSMProvider**: Multi-endpoint Overpass with cache-first loading
- **VenueDataLoader**: berlin-vegan.de JSON with timeout + cache
- **FavoritesManager**: QSettings persistence
- **ReverseGeocoder**: Nominatim background street lookup

### CMake Patterns
- `qt_add_qml_module` with `NO_RESOURCE_TARGET_PATH` (required for Felgo)
- `qt_add_resources` for assets (no resources.qrc)
- `qt_add_translations` with `LRELEASE_OPTIONS -idbased`
- C++ SOURCES in qt_add_qml_module (not qt_add_executable)

## Git Conventions

- Author: `micu <micuintus@gmx.de>`
- No Co-Authored-By lines
- Descriptive commit messages
- License headers in new files

## Before Committing

- Build with Ninja: `ninja -C build`
- Run all 68 tests: all 5 test suites pass
- Check runtime: clean console (only Felgo boilerplate)
