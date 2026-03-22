# Berlin-Vegan App - Development Guide

## Overview

Cross-platform mobile guide for discovering vegan/vegetarian venues in Berlin.
~300+ restaurants, cafes, bars, shops with GPS sorting, multi-dimensional filtering,
opening hours intelligence, favorites, and map views.

## Platforms & Build Systems

| Platform | Build System | Qt Version | UI Toolkit | C++ Standard |
|----------|-------------|------------|------------|-------------|
| SailfishOS | QMake (`BerlinVegan.pro`) | Qt 5.6 | Sailfish Silica | C++17 (GCC 8.3) |
| iOS/Android/Desktop | CMake (`CMakeLists.txt`) | Qt 6.8+ | Felgo 4.3+ | C++17 |

## Build Commands

### Felgo (Desktop/iOS/Android)
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/path/to/felgo
make -j$(nproc)
```

### SailfishOS
```bash
qmake BerlinVegan.pro && make
```

### Tests
```bash
cd tests && qmake ../BerlinVeganTests.pro && make && ./BerlinVeganTests
```

## Project Structure

```
harbour-Berlin-Vegan/
├── src/                         # C++ backend (platform-agnostic)
│   ├── BerlinVegan.cpp          # Entry point (#ifdef Q_OS_SAILFISH)
│   ├── VenueModel.h/cpp         # Data model (QStandardItemModel)
│   ├── VenueSortFilterProxyModel.h/cpp  # Filter/sort engine (630 lines)
│   ├── VenueHandle.h            # QML property proxy per venue
│   ├── OpeningHoursAlgorithms.h # Opening hours parsing + holidays
│   └── FileIO.h/cpp             # File I/O utility
│
├── qml/                         # Shared QML pages
│   ├── harbour-berlin-vegan.qml # Root ApplicationWindow
│   ├── pages/                   # VenueList, VenueDescription, Filter, Map, About
│   └── cover/                   # Sailfish cover page
│
├── components-felgo/            # Felgo platform components (at root, NOT inside qml/)
│   ├── qml/                     # Platform.qml, Theme.qml, Page.qml, etc.
│   └── CMakeLists.txt           # Registers as BerlinVegan.components.platform
│
├── components-sailfish/         # Sailfish platform components (at root)
│   ├── *.qml                    # Platform.qml, Theme.qml, Page.qml, etc.
│   └── qmldir                   # Registers as BerlinVegan.components.platform
│
├── components-generic/          # Shared business components (at root)
│   ├── qml/                     # VenueListItem, VenueDetails, Database.js, etc.
│   └── CMakeLists.txt           # Registers as BerlinVegan.components.generic
│
├── tests/                       # Qt Test unit tests
├── translations/                # i18n (.ts/.qm): de, en, nl
├── android/                     # AndroidManifest.xml
├── ios/                         # Info.plist, assets
└── rpm/                         # SailfishOS RPM packaging
```

**Important**: Component directories are at the **repository root**, not inside `qml/`.

## Architecture

### Data Flow
```
JSON (berlin-vegan.de) → JsonDownloadHelper.qml → JSON.parse() in QML
  → VenueModel.importFromJson() (C++) → VenueSortFilterProxyModel (C++)
    → VenueHandle (C++) → QML Pages
```

### C++ Core
- **VenueModel**: QStandardItemModel with macro-generated roles (`ROLE_NAME_ID_PAIRS`)
- **VenueSortFilterProxyModel**: OR filters (type/subtype/veg), AND filters (properties),
  distance sort, opening hours, search with umlaut normalization
- **VenueHandle**: Auto-generated Q_PROPERTY per role via same macro system
- **OpeningHoursAlgorithms**: Parsing, condensation, Berlin public holidays

### Platform Abstraction (4 Layers)

1. **Build-time selection**: `#ifdef Q_OS_SAILFISH` in C++, `packagesExist(sailfishapp)` in QMake
2. **QML module system**: Both platforms register `BerlinVegan.components.platform 1.0`
3. **Wrapper components**: Page, MenuItem, ListView, Label, Map, etc. delegate to platform primitives
4. **Theme abstraction**: `BVApp.Theme` singleton with platform-specific style properties

### Known Issues

- **UI blocks on filter changes**: Synchronous `invalidateFilter()` does ~6,000 data lookups on UI thread
- **Felgo UX limited**: Felgo wrappers are minimal (now unblocked for improvement)
- **C++11 declared** but Qt6 requires C++17 minimum
- **Memory leak**: `new VenueHandle()` without QML ownership management
- **God object**: Root QML creates all models, manages state, handles favorites

## Revamp Goals (Priority Order)

1. ~~**C: Unified Abstraction**~~ DONE - silica4felgo deleted, 4-layer architecture
2. **B: Better Architecture** - Fix UI blocking, C++ service layer, DataRepository
3. **A: Idiomatic Code** - C++17, QAbstractListModel, constexpr, QML_ELEMENT
4. **D: Multi-Source Data** - OSM (Overpass API), Geoapify, abstract provider interface
5. **E: Sailfish Foundation** - Evaluate Chum Qt6 + Kremnium

## Code Style

- **C++**: 4 spaces, `#pragma once`, PascalCase classes, camelCase methods, `m_` member prefix
- **QML**: 4 spaces, imports grouped (Qt → Silica → BVApp → harbour.berlin.vegan)
- **Translations**: `qsTrId("id-descriptive-name")` with `//%` source comments
- **Logging**: `qInfo()`, `qWarning()`, `qDebug()`, `qCritical()`
- **License**: GPL v2+ header required on new files
