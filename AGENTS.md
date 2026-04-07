# Berlin-Vegan App — AI Agent Context

> This file provides comprehensive context for AI agents (GitHub Copilot, Claude Code,
> Cursor, etc.) working on this repository. Read this before making any changes.
> See also: CLAUDE.md (build commands + code style) and CLAUDE.context.md (full research
> archive and session history).

---

## Project Overview

Cross-platform mobile guide for discovering vegan/vegetarian venues in Berlin metro area.
~3000+ venues from OpenStreetMap + ~227 curated venues from berlin-vegan.de, with GPS
sorting, multi-dimensional filtering, opening hours intelligence, favorites, and map views.

**Active branch**: `feature/application_revamp`
**Commit authorship**: Always `micu <micuintus@gmx.de>` — no Co-Authored-By, no AI mentions

---

## Platform Architecture

### Three build targets — one shared QML codebase

| Track | Platform Layer | Targets | Map | Build | Status |
|-------|---------------|---------|-----|-------|--------|
| **Felgo** | `components-platform/felgo/` | Google Play, iOS | Felgo AppMap (MapLibre) | CMake + Felgo SDK | Working |
| **Kirigami** | `components-platform/kirigami/` | F-Droid, Sailfish CHUM, Linux desktop | MapLibre Native Qt | CMake + Qt6 + KF6 | Planned |
| **Silica** | `components-platform/sailfish/` | Sailfish OS Harbour | Qt Location 5.x | QMake or CMake + Qt5 | Active — invest where justifiable |

### How the abstraction works

Both `BerlinVegan.components.platform` and `BerlinVegan.components.ui` are imported as
`BVApp` in shared QML. This is intentional — shared code writes `BVApp.Label`,
`BVApp.Theme`, `BVApp.Page` etc. without knowing which platform provides the implementation.

Each platform layer must export the same **31 QML types** under the URI
`BerlinVegan.components.platform`:

```
singleton Theme        singleton Platform
ApplicationWindow      Page                 NavigationMenu
MenuItem               ActionMenuItem       NavigationStackWithPushAttached
Label                  ListItem             ListView
Flickable              ScrollDecorator      DetailItem
SectionHeader          Separator            PageHeader
Image                  SearchField          TextSwitch
CustomOpenTextSwitch   ValueSelector        Button
IconButton             BusyIndicator        Map
MapReCenterButton      OpacityRampEffect    CoverBackground
CoverAction            CoverActionList
```

---

## Sailfish Build System: QMake or CMake?

The Sailfish build currently uses `BerlinVegan.pro` (QMake). However:

**Sailfish SDK 3.3+ supports CMake natively** via `sfdk cmake`. The official documentation
states: "native support is only available for projects that use either qmake or CMake."
There is an official CMake sample: https://github.com/sailfishos/cmakesample

**Migrating the Sailfish build to CMake is viable** but not yet decided. Caveats:
- Qt5 CMake patterns differ from Qt6: `qt_add_qml_module` is Qt6-only; Qt5 uses
  `qt5_add_resources`, `qt5_create_translation`, etc.
- `sailfishapp` must be found via `pkg_check_modules(sailfishapp REQUIRED sailfishapp)`
  instead of `CONFIG += sailfishapp`

**Current state of `BerlinVegan.pro`**: Stale — missing C++ classes added during the
Felgo/Qt6 work (`ReverseGeocoder`, `OsmOpeningHoursParser`, `MapBearingLock`). Needs
updating before the Sailfish build will compile again.

---

## C++ Backend

All C++ types use Qt6 QML registration macros (no `qmlRegisterType`):

| Class | Registration | Purpose |
|-------|-------------|---------|
| `VenueModel` | `QML_ELEMENT` | QStandardItemModel, macro-generated roles, OSM dedup |
| `VenueSortFilterProxyModel` | `QML_ELEMENT` | OR/AND filters, distance sort, deferred invalidation |
| `VenueHandle` | `QML_ELEMENT` | QML property proxy per venue |
| `OSMProvider` | `QML_SINGLETON` | Overpass API client, cache-first loading |
| `VenueDataLoader` | `QML_SINGLETON` | berlin-vegan.de JSON loader, network + cache + bundled fallback |
| `FavoritesManager` | `QML_SINGLETON` | QSettings-based persistence |
| `ReverseGeocoder` | C++ service | Nominatim street lookup |
| `OsmOpeningHoursParser` | C++ | Parses "Mo-Fr 09:00-18:00" format (~90% OSM coverage) |
| `OpeningHoursAlgorithms` | C++ | Opening hours computation + Berlin holidays |
| `MapBearingLock` | `QML_ELEMENT` | Synchronous bearing reset for maps |
| `TruncationMode` | `QML_UNCREATABLE` | Enum: None=0, Elide=1, Fade=2 |

---

## Map Implementation

### Felgo track (current, working)
- Uses `Felgo.AppMap` which wraps Qt Location Map with MapLibre plugin
- Tile style: `https://tiles.openfreemap.org/styles/liberty` (free, no API key)
- `showUserPosition: true` for user location dot
- Custom double-tap and hold-drag-zoom implemented via `Timer` (300ms window) because
  Felgo's `ApplicationWindow` intercepts touches and breaks Qt's built-in `tapCount`
- Rotation locked: `onBearingChanged: if (bearing !== 0.0) bearing = 0.0`
- See: `components-platform/felgo/qml/Map.qml`

### Kirigami track (planned)
- Will use `QtLocation.Map` with the `"maplibre"` Qt Location plugin (QMapLibre)
- QMapLibre integrated as git submodule (`extern/qmaplibre/`) installed into Qt prefix
- Gesture code ported from `parklibre` reference app (`/Users/michael.voigt/devel/parklibre/`)
- `QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL)` required in main.cpp
- Pattern:
  ```qml
  QL.Map {
      plugin: Plugin {
          name: "maplibre"
          parameters: [ PluginParameter {
              name: "maplibre.map.styles"
              value: "https://tiles.openfreemap.org/styles/liberty"
          }]
      }
  }
  ```

---

## Code Style & Conventions

See CLAUDE.md for the full style guide. Summary:

- **C++**: 4 spaces, `#pragma once`, PascalCase classes, camelCase methods, `m_` member prefix
- **QML**: 4 spaces, bare imports (no version numbers), `BVApp` alias for platform/ui modules
- **Translations**: `qsTrId("id-descriptive-name")` with `//%` source comments, `-idbased`
- **No `qmlRegisterType`** anywhere — use `QML_ELEMENT`/`QML_SINGLETON`/`QML_UNCREATABLE`

---

## Build Commands

### Felgo/Qt6 (desktop)
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_PREFIX_PATH=/path/to/felgo -GNinja
ninja
```

### Android APK
```bash
ninja -C build-android harbour-berlin-vegan_make_apk
```
Note: The `BUILD SUCCESSFUL` / `ninja: build stopped: subcommand failed` is a known
androiddeployqt/Gradle quirk. The APK is valid.

### Tests
```bash
ninja -C build tst_osm_opening_hours tst_opening_hours_algorithms tst_deduplication
build/tests/tst_osm_opening_hours        # 21 tests
build/tests/tst_opening_hours_algorithms  # 18 tests
build/tests/tst_deduplication             # 11 tests
```

### Sailfish (QMake, via Sailfish SDK)
```bash
sfdk config target=SailfishOS-<version>-armv7hl
sfdk build   # from project root
```
Or with CMake (SDK 3.3+):
```bash
sfdk cmake .. [cmake-options]
sfdk make
sfdk package
```

---

## Key Shared QML Files

| File | Purpose |
|------|---------|
| `qml/harbour-berlin-vegan.qml` | Root ApplicationWindow + NavigationMenu + data loading |
| `qml/pages/VenueList.qml` | Main venue list; uses `pageStack.pushAttached()` to map |
| `qml/pages/VenueDescription.qml` | Venue detail (Flickable-based) |
| `qml/pages/VenueFilterSettings.qml` | ~15 TextSwitch toggles + ValueSelector |
| `qml/pages/VenueMapOverviewPage.qml` | Full-screen map with venue markers |
| `qml/pages/AboutBerlinVegan.qml` | About page; most `Platform.isFelgo/isSailfish` uses |
| `qml/components/VenueListItem.qml` | List delegate |
| `qml/components/VenueDetails.qml` | 12 DetailItem rows for venue properties |
| `qml/components/VenueDescriptionHeader.qml` | Photo swiper + header |
| `qml/components/VenueMapWidget.qml` | Inline mini-map on detail page |
| `qml/components/IconToolBar.qml` | Call/fav/website action bar |
| `components-ui/qml/CollapsibleItem.qml` | Uses `BVApp.OpacityRampEffect` |

---

## Current Open Tasks

1. **Small redesign improvements** on the Felgo build (user to specify)
2. **Confirm hold-drag zoom** on device (not yet user-verified)
3. **Run full test suite** after recent changes (all 50 tests should pass)
4. **PR/merge** `feature/application_revamp` → `main`
5. **Update `BerlinVegan.pro`** to include new C++ sources (ReverseGeocoder,
   OsmOpeningHoursParser, MapBearingLock)
6. **Implement Kirigami platform layer** (see CLAUDE.context.md Section 8 for full plan)

---

## Important Constraints

- **Never** use `qmlRegisterType` — use `QML_ELEMENT`/`QML_SINGLETON`
- **Never** add version numbers to QML imports — use bare imports
- **Never** commit with Co-Authored-By or any AI attribution
- **Never** create documentation files unless explicitly requested
- **Always** use `qsTrId()` + `//%` comments for user-visible strings
- When adding new C++ classes: add to BOTH `CMakeLists.txt` AND `BerlinVegan.pro`
- When modifying shared QML: verify it doesn't break the Sailfish platform layer

---

## Reference Apps & Paths

| Resource | Path |
|----------|------|
| parklibre (Qt6+MapLibre reference) | `/Users/michael.voigt/devel/parklibre/` |
| Felgo SDK QML sources | `/Users/michael.voigt/Felgo/Felgo/macos/qml/` |
| Sailfish CMake sample | https://github.com/sailfishos/cmakesample |
| Pure Maps (Kirigami/Silica pattern) | https://github.com/rinigus/pure-maps |

---

*For the full research archive (Jolla health, Qt6 roadmap, CRA implications, Qt licensing,
Kirigami component mapping), see CLAUDE.context.md.*
