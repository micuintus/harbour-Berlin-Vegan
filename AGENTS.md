# Agent Guidelines for Berlin-Vegan

## Project Overview

Berlin-Vegan is a Qt/QML cross-platform mobile app for SailfishOS, iOS, and Android. It displays vegan food and shopping locations in Berlin.

- **Platforms**: SailfishOS (native), iOS/Android (via Felgo)
- **Languages**: C++17, QML, JavaScript
- **Build Systems**: QMake (.pro files) and CMake
- **License**: GPL v2 or later

## Build Commands

### Using QMake (SailfishOS SDK)

```bash
# Build the main application
qmake BerlinVegan.pro
make

# Build tests
qmake BerlinVeganTests.pro
make

# Run tests
./BerlinVeganTests

# Run a single test class
./BerlinVeganTests testFunctionName
```

### Using CMake (Felgo/Desktop)

```bash
# Configure and build
mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/path/to/felgo
make -j$(nproc)

# Build with specific config
cmake --build . --config Release
```

### Translation/L10n

```bash
# Update translation files (requires sailfishapp_i18n in .pro)
lupdate BerlinVegan.pro

# Release translations
lrelease BerlinVegan.pro
```

## Test Commands

Tests use Qt Test framework:

```bash
# Build and run all tests
cd tests
qmake ../BerlinVeganTests.pro
make
./BerlinVeganTests

# Run specific test function
./BerlinVeganTests testIsPublicHoliday

# Run tests with verbose output
./BerlinVeganTests -v2

# List all test functions
./BerlinVeganTests -functions
```

## Code Style Guidelines

### C++ Style

- **Standard**: C++17
- **Indentation**: 4 spaces (no tabs)
- **Headers**: Use `#pragma once` instead of include guards
- **Line length**: ~120 characters max

#### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `VenueModel`, `VenueSortFilterProxyModel` |
| Methods/Functions | camelCase | `importFromJson()`, `setFavorite()` |
| Member Variables | m_ prefix + camelCase | `m_loadedVenueType` |
| Constants | UPPER_CASE or PascalCase | `DAYS_PER_WEEK`, `VenueType::Gastro` |
| Enums | PascalCase | `enum VenueVegCategory` |
| Macros | UPPER_CASE | `ROLE_NAME_ID_PAIRS` |

#### File Organization

```cpp
// 1. License header (mandatory for new files)
/**
 * This file is part of the Berlin-Vegan guide
 * Copyright 20XX (c) by <author>
 * Licensed under GPL v2 or later
 */

// 2. Includes - Qt first, then local
#include <QtCore/QHash>
#include <QStandardItemModel>
#include "VenueModel.h"
#include "FileIO.h"

// 3. Forward declarations
class QReadWriteLock;
class QQmlEngine;

// 4. Inline helpers before classes
constexpr inline int enumValueToFlag(const int enumValue) { ... }
```

### QML Style

- **Indentation**: 4 spaces
- **Imports**: Group by source (Qt -> Sailfish -> local)

```qml
import QtQuick 2.5
import Sailfish.Silica 1.0
import QtPositioning 5.2

import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.generic 1.0 as BVApp

import harbour.berlin.vegan 1.0
```

#### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| IDs | camelCase | `id: page`, `id: listView` |
| Properties | camelCase | `property var restaurant` |
| Functions | camelCase | `function updatePosition() {}` |
| Translation IDs | id-<name> | `qsTrId("id-filter-page-title")` |

#### Translation

Always use `qsTrId()` with id-based translations:

```qml
// Good
Label {
    //% "Filter settings"
    text: qsTrId("id-filter-page-title")
}

// Context comments use //%
```

### Project Structure

**Important**: Component directories are at the **repository root**, not inside `qml/`.

```
harbour-Berlin-Vegan/
├── src/                         # C++ source files
├── qml/                         # Shared QML pages and cover
│   ├── pages/                   # Page components
│   └── cover/                   # Sailfish cover page
├── components-felgo/            # Felgo platform components (ROOT level)
│   └── qml/                     # Platform.qml, Theme.qml, Page.qml, etc.
├── components-sailfish/         # Sailfish platform components (ROOT level)
├── components-generic/          # Shared business components (ROOT level)
│   └── qml/
├── silica4felgo/                # Sailfish.Silica compatibility shim
│   └── qml/
├── tests/                       # Qt Test unit tests
├── translations/                # .ts translation files (de, en, nl)
├── android/                     # Android-specific files
├── ios/                         # iOS-specific files
└── rpm/                         # Sailfish RPM packaging
```

## Error Handling

- Use Qt's logging: `qInfo()`, `qWarning()`, `qDebug()`, `qCritical()`
- Return meaningful error states for model operations
- Validate JSON inputs before processing

## Platform Abstraction

The app uses platform-specific components:

- **SailfishOS**: Native Silica components in `components-sailfish/`
- **iOS/Android**: Felgo components in `components-felgo/`
- **Shared**: Common components in `components-generic/`

Use `#ifdef Q_OS_SAILFISH` for platform-specific C++ code.

## Model/View Architecture

- **VenueModel**: Core data model (QStandardItemModel subclass)
- **VenueSortFilterProxyModel**: Sorting and filtering proxy
- **VenueHandle**: Handle to venue data
- Roles are defined via macros in VenueModel.h

## Git Conventions

- Feature branches from master
- Descriptive commit messages
- Include license headers in new files
- Test on both Sailfish and Felgo when possible

## Lint/Format

No automated linter configured. Follow existing code style manually.

Before committing:
- Verify builds with both QMake and CMake
- Run unit tests: `./BerlinVeganTests`
- Check translations compile
- Test on target platform if possible
