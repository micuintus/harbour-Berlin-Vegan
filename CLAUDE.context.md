# Berlin-Vegan App — Claude Session Context & Research Archive

> Preserves all findings, decisions, and plans from the 2026 development sessions so work
> can be resumed with full context. Keep this file updated as work progresses.
> Last updated: April 2026.

## Table of Contents

1. [Current State of the Codebase](#1-current-state-of-the-codebase)
2. [Completed Code Work](#2-completed-code-work)
3. [Platform Strategy Decision](#3-platform-strategy-decision)
4. [Sailfish OS & Qt6 Research](#4-sailfish-os--qt6-research)
5. [Jolla Health Assessment](#5-jolla-health-assessment)
6. [EU Cyber Resilience Act (CRA) Impact](#6-eu-cyber-resilience-act-cra-impact)
7. [Qt Licensing Constraints](#7-qt-licensing-constraints)
8. [Kirigami Platform Layer Plan](#8-kirigami-platform-layer-plan)
9. [parklibre MapLibre Reference](#9-parklibre-maplibre-reference)
10. [Key Files Reference](#10-key-files-reference)
11. [Open Items & Next Steps](#11-open-items--next-steps)

---

## 1. Current State of the Codebase

### Branch: `feature/application_revamp`

Git history was cleaned from 58 commits → ~16 clean, self-contained commits via interactive
rebase. All commits authored as `micu <micuintus@gmx.de>`, no AI mentions anywhere.

### What's working (Felgo/Qt6 build)

- **Felgo/Qt6 desktop build**: Compiles and runs
- **Android APK**: `ninja -C build-android harbour-berlin-vegan_make_apk` → valid 55MB debug APK.
  The `BUILD SUCCESSFUL` / `ninja: build stopped: subcommand failed` is a known
  androiddeployqt/Gradle quirk — the APK is valid regardless.
- **Map**: Felgo AppMap with MapLibre tiles (OpenFreeMap liberty style)
- **Double-tap zoom**: Working via Timer-based detection (immune to Felgo's touch interception)
- **Double-tap-hold-drag zoom**: Working via DragHandler enabled during Timer window
- **Rotation lock**: `onBearingChanged: if (bearing !== 0.0) bearing = 0.0`
- **Location marker**: `showUserPosition: true` on AppMap
- **Drawer**: No overlap with nav bar (`drawerLogoHeight: parent.navigationBar.height`)
- **OSM data**: ~3000+ venues loaded via Overpass API with deduplication
- **berlin-vegan.de data**: ~227 curated venues with photos and bilingual descriptions
- **Tests**: 50 tests across 3 executables (tst_osm_opening_hours, tst_opening_hours_algorithms,
  tst_deduplication)

### User-confirmed features
- Double-tap zoom ✅
- Location marker visible ✅
- Rotation blocked ✅
- Hold-drag zoom — NOT yet confirmed by user (needs testing)

### Sailfish/Qt5 build status
- `BerlinVegan.pro` exists but is **stale** — missing new C++ classes added during the
  Felgo/Qt6 work: `MapBearingLock`, `ReverseGeocoder`, `OsmOpeningHoursParser` (and any
  others added since)
- `components-platform/sailfish/` — 32 Silica wrapper QML files, still functional but
  not tested against the latest shared QML changes
- Updating the Sailfish build to full parity is a planned task (see Section 11)

---

## 2. Completed Code Work

### Map Rewrite
Replaced raw `QL.Map` + ~256 lines of broken custom gesture code with `Felgo.AppMap`.

**Key file**: `components-platform/felgo/qml/Map.qml` (123 lines)

Implementation details:
- Uses `Felgo.AppMap` which extends Qt Location Map with built-in user position and gestures
- MapLibre plugin: `plugin: "maplibre"` with style `https://tiles.openfreemap.org/styles/liberty`
- `showUserPosition: true` for the blue location dot
- Rotation locked via `onBearingChanged: if (bearing !== 0.0) bearing = 0.0`
- Double-tap zoom uses a `Timer` (300ms) instead of `TapHandler.onDoubleTapped` because
  Felgo's `ApplicationWindow` installs touch interception that breaks Qt's built-in `tapCount`
- Double-tap-hold-drag-to-zoom: `DragHandler` enabled only during the Timer window, with
  `_holdZoomActive` flag to prevent Qt from canceling the grab mid-drag
- Pattern ported from parklibre's `ParkMap.qml`

### Drawer Overlap Fix
**File**: `components-platform/felgo/qml/NavigationMenu.qml`
- `drawerLogoHeight: parent.navigationBar.height` prevents Android drawer from protruding
  into the navigation bar area

### OSM Filter Label Rename
Changed "OpenStreetMap (community)" → "OpenStreetMap venues" in all 3 translation files:
- `translations/harbour-berlin-vegan-de.ts`
- `translations/harbour-berlin-vegan-en.ts`
- `translations/harbour-berlin-vegan-nl.ts`

### Code Review Fixes (Ralph Loop)
Found and fixed bugs in:
- `ReverseGeocoder` — error handling improvements
- `VenueModel` — data import edge cases
- `OSMProvider` — API client robustness
- Opening hours parsing — edge case fixes

### Git History Cleanup
58 messy commits → ~16 clean squashed commits with descriptive messages. Each commit is
self-contained and reviewable. All authored as `micu <micuintus@gmx.de>`.

---

## 3. Platform Strategy Decision

### Decided: Three tracks

| Track | Platform Layer Dir | Targets | Map Solution | Build System | Status |
|-------|--------------------|---------|-------------|-------------|--------|
| **Felgo** | `components-platform/felgo/` | Google Play, iOS | Felgo AppMap (MapLibre) | CMake + Felgo SDK | **Working** |
| **Kirigami** | `components-platform/kirigami/` | F-Droid, Sailfish CHUM, desktop Linux | MapLibre Native Qt (QMapLibre) | CMake + Qt6 + KF6 | **Planned** |
| **Silica** | `components-platform/sailfish/` | Sailfish Harbour | Qt Location 5.x (OSM) | QMake or CMake + Qt5 | **Active — invest where effort is justifiable** |

### Rationale
- **Felgo** earns its keep on iOS and Google Play (AppMap, native feel, store deployment)
- **Kirigami** serves F-Droid (open source requirement, no Felgo dependency) AND Sailfish CHUM
  AND desktop Linux — one platform layer, three targets. This is the **Pure Maps model**
  (rinigus: `platform.silica/` + `platform.kirigami/`)
- **Silica/Qt5** is actively maintained for Sailfish Harbour users. Investment continues where
  effort is justifiable relative to the user base and platform trajectory. The goal is to keep
  feature parity where practical, recognizing that some features (e.g., MapLibre tiles) may
  not be available on Qt5/Silica.

### Note on the Sailfish build system: QMake vs CMake
**Sailfish SDK 3.3+ supports CMake natively** via the `sfdk cmake` command. The official docs
state: "native support is only available for projects that use either **qmake or CMake**."
There is even an official CMake sample app (`github.com/sailfishos/cmakesample`).

This means `BerlinVegan.pro` is not forced on us. Options:
1. **Keep QMake**: Simple, well-understood for Sailfish. The `CONFIG += sailfishapp` approach
   is mature and documented.
2. **Migrate to CMake**: Unifies the build system. Caveat: Qt5 CMake patterns differ from Qt6
   (`qt_add_qml_module` is Qt6-only; Qt5 uses `qt5_add_resources`, `qt5_create_translation`,
   etc.). The `sailfishapp` library would need to be found via `pkg_check_modules(sailfishapp
   REQUIRED sailfishapp)`.

**Decision not yet made** — evaluate when the Sailfish build update is tackled.

### Key architectural insight
Both `BerlinVegan.components.platform` and `BerlinVegan.components.ui` are imported as `BVApp`
in shared QML — deliberately merged into one namespace so shared code uses `BVApp.Label`,
`BVApp.Theme`, etc. without caring which platform module provides the implementation.

---

## 4. Sailfish OS & Qt6 Research

### Summary: Is there hope for Jolla porting to Qt6?

**Short answer: Some hope, but not on any timeline that matters for planning.**

Glimmers of hope:
- Low-level libraries (libmlocale, mapplauncherd-qt, libresourceqt, libcontentaction) are
  getting Qt6 compat PRs — bottom-up infrastructure groundwork
- JoshStrobl (Jolla) floated "hypothetically two Silica versions" (Qt5 closed + Qt6 open)
- Jolla employees review and merge these Qt6 PRs (pvuorela)
- CRA pressure (Dec 2027 deadline) will eventually force their hand
- J2 revenue *could* fund Qt6 work if commercially successful

Cold reality:
- **The licensing trilemma blocks them** (see Section 7): LGPL v3 requires bootloader unlock
  OR a commercial Qt license ($100K–500K/yr). Neither is palatable.
- Even starting tomorrow: 6–12 months minimum with a focused team — they have ~50 people
  running an entire OS + Android compat + B2B product line
- **J2 will ship and live its life on Qt5.** That is essentially certain.
- The Qt6 compat PRs are mostly from **neochapay (NemoMobile)**, not a Jolla initiative
- Aurora OS went "bundle Qt6 per-app" rather than system migration — even well-funded forks
  gave up on system-wide Qt6

**Assessment**: 30% chance of system-wide Qt6 within 3 years, 60% within 5 years, but only
if J2 is commercially successful AND they resolve the licensing issue. Do not plan around it.

### Round 1: IRC Meeting Logs & Community Research

- Reviewed 30+ IRC community meeting logs (2024–2025): Qt6 never mentioned once by Jolla
- Community Qt6 port via **sailfishos-chum** (maintainer: rinigus): 30+ Qt6 modules
  including qtbase, qtdeclarative, qtlocation, qtpositioning, qtwayland, qt5compat,
  plus 36+ KDE Frameworks 6 packages including Kirigami
- **Silica and Qt6 are physically incompatible**: Silica is a closed-source Qt5 QML plugin;
  the Qt6 QML engine cannot load Qt5 QML plugins
- **Pure Maps** (rinigus) is the gold standard multi-platform pattern:
  `platform.silica/` + `platform.kirigami/` directories

### Round 2: Forum Thread Research

- **decon** announced a Silica-for-Qt6 port on December 30, 2025
- Basic functionality claimed: PageStack/Pages, PullDown/PushUp menus, Buttons, Icons,
  ComboBoxes, ContextMenus
- **NOT published** — no code as of April 2026 (3+ months of silence)
- 26 forum likes (highest engagement in the thread) — strong community demand
- JoshStrobl (Jolla employee) confirmed talks about hypothetically two Silica versions:
  one in Qt6 for open source, one in Qt5 for business
- Forum: https://forum.sailfishos.org/t/upgrading-silica-to-qt6/26712
- JoshStrobl: https://forum.sailfishos.org/t/android-enshittification-process-lets-promote-sailfish-os/24976/31
- **Verdict**: Promising but unproven. Comparable project (Glacier UI qtquickcontrols-nemo)
  took years to reach v6.3.0. Do not plan around decon's port.

### Round 3: Jolla Phone J2 & Latest Development

- **J2 is real**: 10,000+ pre-orders, MediaTek Dimensity 7100, manufactured by Reeder
- Mass production & first batch shipping end of June 2026
- Reeder is proven — they already delivered the C2 device successfully

Qt6 movement in Jolla's GitHub repos:
- libmlocale, mapplauncherd-qt, libresourceqt, libcontentaction all receiving Qt6 compat PRs
- Most PRs from neochapay (NemoMobile/Glacier UI), not from Jolla employees
- pvuorela (Jolla) reviews/merges them — Jolla acts as upstream receiver, not initiator
- Sailfish OS 5.0.0.77 released March 2026 (14 point releases over 17 months)
- Infrastructure modernizing: PulseAudio 17.0, GStreamer 1.26, BlueZ 5.86, FFmpeg 5.1.8,
  glibc 2.43 prep — but **Qt 5.6 remains the ceiling**

### Round 4: Six Deep Dives

#### 4a. Jolla's Qt Patch Set
- Fork of Qt 5.6 at `github.com/sailfishos/`
- Carries years of patches: Wayland compositor integration, Silica hooks, hardware
  optimizations, security backports, lipstick private API usage
- Rebasing on Qt 6 estimated at 6–12 months for a focused team
- The fork's complexity is a major barrier

#### 4b. CHUM Qt6 Packages
- 27 Qt6 modules (Qt 6.8.3 LTS), 36+ KDE Frameworks 6 packages including Kirigami
- Clean Qt5/Qt6 coexistence via separate install paths and `qt-runner` launcher
- **Zero production apps** shipping on CHUM Qt6 as of April 2026
- **No viable map component** for Qt6 on Sailfish yet (Felgo's AppMap is commercial;
  Qt Location MapLibre plugin not yet packaged for CHUM Qt6)
- Foundation exists but not mature enough for production use today

#### 4c–4f. See Sections 6 and 7 below.

### Aurora OS Findings
- Aurora has Qt6 repos on Mos.Hub marked "Experimental — sideload" (per-app bundling,
  not system-wide migration)
- Aurora investing heavily in Flutter, PWA, Chromium WebView
- Communities severed from Sailfish — no bidirectional code sharing
- **There is no "Qt6 from Aurora" that Jolla could adopt**

---

## 5. Jolla Health Assessment

### Financial Health
- J2 pre-orders: 10,000+ at ~€400–500 per device
- Revenue: AppSupport B2B licensing, Sailfish X subscriptions, device sales
- Lost Russian/Aurora revenue (~75% of company) after 2022 sanctions
- Management buyout (MBO) completed — team personally invested in the outcome
- ~50 employees — borderline for maintaining full OS + Android compat + B2B
- 3 near-death experiences: 2015 (tablet failure), 2022 (Russia sanctions), 2024 (unclear)
- MWC Barcelona 2026 presence; Finnish Transport Minister visited their booth

### Community Health
- **Very active and growing** — strongest inflection point since 2013–2014 Jolla Phone 1 era
- Forum: 28,900+ topics; "Next gen Jolla Phone" thread: 1,247 replies / 56,152 views
- App ecosystem: ~4,000+ listings across OpenRepos + CHUM + Harbour
- New apps still being created: Automagic, Maelstrom, Mastodon, oebb-ticket, etc.
- Key community contributors: poetaster, nephros, rinigus, abranson, rubdos, piggz
- Key Jolla employees active in community: mal, pvuorela
- Community crowdfunded a J2 for poetaster — shows mutual community–company support
- J2 hype is real but execution risk remains

### Competitive Landscape
- Sailfish OS is arguably the most commercially viable alternative mobile OS in 2026
- Unique advantages: Android 13 app support, 12+ year platform maturity, B2B AppSupport
  product, and now a purpose-built phone (J2)
- **/e/OS**: 271 device models, pragmatic degoogled Android fork — different market segment
- **Pine64**: Honest low-expectations hardware, community-driven
- **Purism**: Cautionary tale — Librem 5 was 3 years late, refund scandals, broken trust
- **Ubuntu Touch (UBports)**: Foundation-backed, steady development, small user base
- **J2 vs Purism Librem 5**: Proven manufacturer (Reeder delivered C2), pre-order not
  crowdfunding, mature software stack already running on real hardware
- No alternative mobile OS company has solved sustainable economics. Jolla's best path is
  AppSupport B2B licensing with phones as brand-building.

### Technical Trajectory
- Sailfish OS 5.0.0.77 released March 2026; 5.1 branching imminent
- Browser: Gecko ESR91 (4+ years behind); ESR102 migration in progress
- Android AppSupport: Android 13 (API 33) on all supported devices
- Infrastructure modernizing (see Round 3 above)
- **Qt 5.6 remains the ceiling** — no migration path announced
- SDK 3.12 (Feb 2025) current and maintained. sfdk supports both QMake and CMake.
- 950 public repos on GitHub, active development

### Historical Crises Pattern
1. **2014**: Tablet crowdfunded ~$2.5M → never fully delivered
2. **2015–2016**: Corporate restructuring under Finnish rehabilitation
3. **2020–2022**: Rostelecom/Aurora partnership → lost after Russia sanctions
4. **2024**: Another crisis → management buyout (MBO)
- **Pattern**: Survive through external rescue, not organic growth
- **J2 is structurally different**: proven manufacturer, pre-order model, mature software

---

## 6. EU Cyber Resilience Act (CRA) Impact

**Regulation**: (EU) 2024/2847

### Timeline
- **Sept 11, 2026**: Must report actively exploited vulnerabilities within 24 hours
- **Dec 11, 2027**: Full application — cannot place products with known exploitable
  vulnerabilities on the EU market

### Key implications for Jolla/J2
- **No small-batch exemption**: 10K units is irrelevant
- **No open-source exemption for manufacturers**: Exemption is for non-commercial open
  source stewards only, not companies selling devices
- Qt 5.6 has **known unpatched CVEs**: HTTP/2 handling, SVG parsing, XML parsing, BLE stack
- Gecko ESR 91 (browser): 4+ years of unfixed CVEs — even worse
- **5-year support period** required → vulnerability handling through 2031–2032
- **SBOM requirement** makes the Qt 5.6 dependency visible to market surveillance authorities
- **Penalties**: Up to EUR 15,000,000 or 2.5% of global annual turnover; market withdrawal
  orders possible
- Source: https://eur-lex.europa.eu/eli/reg/2024/2847

### Assessment
CRA is the strongest external pressure forcing Jolla toward Qt6. Dec 2027 gives ~20 months
from April 2026. The J2 will almost certainly ship before any Qt6 migration. Jolla will
likely deal with this reactively rather than proactively.

---

## 7. Qt Licensing Constraints

### The Version Boundary
- **Qt 5.6** = last version under **LGPL v2.1** (allows locked/tivoized devices)
- **Qt 5.7+** = **LGPL v3** (inherits GPL v3 Section 6 anti-tivolization clause)

### The Trilemma Jolla faces

1. **Upgrade Qt (5.7+ or 6.x) under LGPL v3**
   → Must provide "Installation Information" for User Products (phones qualify)
   → Effectively requires unlocking the bootloader so users can replace Qt libraries
   → Puts entire proprietary stack (Silica, Exchange, AppSupport) at legal risk

2. **Buy commercial Qt license** (~$100K–500K/year)
   → Allows keeping device locked
   → Expensive for a ~50-person company
   → The Qt Company aggressively upsells

3. **Stay on Qt 5.6** (current choice)
   → No new licensing issues
   → Technical death: accumulating CVEs, missing APIs, developer attrition
   → CRA exposure from Dec 2027

### Key details
- Silica can remain closed-source under both LGPL versions (dynamic linking is fine)
- The issue is **device lockdown**, not Silica's source code status
- Jolla's strongest counter-argument: Developer mode + root access = users CAN replace Qt .so
  files at runtime; system doesn't verify library signatures
- **No LGPL v3 anti-tivolization case has ever been litigated** — untested legal territory
- Google deliberately avoids LGPL v3 in Android; automotive universally uses commercial licenses

### Reference
- Qt licensing change: https://www.qt.io/blog/2016/01/13/new-agreement-with-the-kde-free-qt-foundation

---

## 8. Kirigami Platform Layer Plan

### Architecture

New `components-platform/kirigami/` directory implementing the same
`BerlinVegan.components.platform` module URI (31 QML components) using Kirigami + QQC2 +
MapLibre Native Qt instead of Felgo. **One platform layer serves three targets**:
F-Droid (Android), Sailfish CHUM (Qt6), and desktop Linux.

### Complete Component Mapping (31 components)

#### Tier 1: Core Shell / Navigation

| BVApp Component | Felgo Base | Kirigami Equivalent | Notes |
|----------------|-----------|-------------------|-------|
| **ApplicationWindow** | `Felgo.App` | `Kirigami.ApplicationWindow` + `globalDrawer` | Set `Kirigami.Theme` for branding colors; portrait lock via `Screen.orientationUpdateMask` |
| **Page** | `Felgo.AppPage` | `Kirigami.Page` / `Kirigami.ScrollablePage` | `activated()` → `onIsCurrentPageChanged`; expose `pageStack` alias → `applicationWindow().pageStack` |
| **NavigationMenu** | `Felgo.Navigation` | `Kirigami.GlobalDrawer` with `actions: [...]` | `headerView` → `GlobalDrawer.header` |
| **MenuItem** | `Felgo.NavigationItem` | `Kirigami.Action` in GlobalDrawer | `pageComponent` → `onTriggered: pageStack.push()`. Split view → Kirigami multi-column `pageStack.columnView` |
| **ActionMenuItem** | extends MenuItem | `Kirigami.Action` with `pageStack.clear(); push()` | Used for Venues + Favorites (replace-stack semantics) |
| **NavigationStackWithPushAttached** | `Felgo.NavigationStack` | **Not needed** | `pushAttached()` becomes toolbar action or secondary Kirigami column. Decision still open. |

#### Tier 2: Content Display

| BVApp Component | Felgo Base | Kirigami Equivalent | Notes |
|----------------|-----------|-------------------|-------|
| **Label** | `QtQuick.Text` | `QQC2.Label` | Map `truncationMode` (0=None, 1=Elide→`Text.ElideRight`, 2=Fade→`OpacityRampEffect`). Default color via Kirigami.Theme |
| **ListItem** | `Felgo.SimpleRow` | `QQC2.ItemDelegate` or `Kirigami.BasicListItem` | Expose `contentHeight`, `contentWidth`, signal `clicked(int index)`, `highlighted` |
| **ListView** | `Felgo.AppListView` | Plain `ListView` | Or inside `Kirigami.ScrollablePage` |
| **Flickable** | `Felgo.AppFlickable` | Plain `Flickable` | Or use `Kirigami.ScrollablePage` (has built-in Flickable) |
| **ScrollDecorator** | Empty `Item` (no-op) | Empty `Item` stub | Kirigami/QQC2 handle scroll indicators natively |
| **DetailItem** | Custom dual-label `Item` | Custom `RowLayout` with two `QQC2.Label` | Props: `label`, `value`, `fontWeight`, `fontSize`(ro), margins(ro), colors(ro). Or use `Kirigami.FormLayout` |
| **SectionHeader** | Custom icon+text `Item` | `RowLayout { Kirigami.Icon {}; Kirigami.Heading { level: 4 } }` | |
| **Separator** | `Rectangle` | `Kirigami.Separator` | Direct equivalent |
| **PageHeader** | Invisible `Item` | Empty `Item` stub | Title shown in Kirigami.Page toolbar. For map overlay: custom `Kirigami.Heading` |
| **Image** | `QtQuick.Image` + PictureViewer | `Image` + fullscreen overlay | `MouseArea` → custom fullscreen layer or `Kirigami.MaximizeComponent` |

#### Tier 3: Input Controls

| BVApp Component | Felgo Base | Kirigami Equivalent | Notes |
|----------------|-----------|-------------------|-------|
| **SearchField** | `Felgo.SearchBar` | `Kirigami.SearchField` | Ignore `flickableForSailfish` (not needed) |
| **TextSwitch** | MouseArea+AppSwitch | `QQC2.CheckDelegate` or Switch+Label row | Must replicate `automaticCheck: false` + `userToggled()` pattern (~15 uses in filter page) |
| **CustomOpenTextSwitch** | MouseArea+Switch+TimePicker+DatePicker | Custom: Switch + time/date picker dialogs | Use `Qt.labs.platform` dialogs or custom QML pickers. Decision still open. |
| **ValueSelector** | Column+AppSlider | `ColumnLayout { QQC2.Label; QQC2.Label (value+unit); QQC2.Slider }` | |
| **Button** | `Felgo.AppButton` | `QQC2.Button` | Direct equivalent |
| **IconButton** | MouseArea+Column(icon+text) | `QQC2.ToolButton` + `Kirigami.Icon` + optional subtitle label | Map `type` string → icon names via Theme |
| **BusyIndicator** | `Felgo.AppActivityIndicator` | `QQC2.BusyIndicator` | Map `size` to width/height |

#### Tier 4: Map

| BVApp Component | Felgo Base | Kirigami Equivalent | Notes |
|----------------|-----------|-------------------|-------|
| **Map** | `Felgo.AppMap` (123 lines) | `QtLocation.Map` + MapLibre plugin + gesture handling from parklibre's `ParkMap.qml` | Need: PositionSource + MapQuickItem for user dot; double-tap, hold-drag, rotation lock |
| **MapReCenterButton** | IconButton in circle+shadow | `QQC2.RoundButton` + "my_location" icon + shadow | |

#### Tier 5: Visual Effects

| BVApp Component | Felgo Base | Kirigami Equivalent |
|----------------|-----------|-------------------|
| **OpacityRampEffect** | `Qt5Compat.GraphicalEffects.OpacityMask` + gradient | Same approach (Qt5Compat available in Qt6). Props: `sourceItem`, `enabled`, `direction`(0–3), `offset`, `slope` |

#### Tier 6: Sailfish-Only Stubs

| BVApp Component | Purpose | Kirigami Equivalent |
|----------------|---------|-------------------|
| **CoverBackground** | Sailfish lockscreen widget | Empty `Item` stub |
| **CoverAction** | Lockscreen action button | Empty `Item` stub |
| **CoverActionList** | Lockscreen action container | Empty `Item` stub |

### Singletons

#### Theme (~200 lines estimated for Kirigami version)

Map to `Kirigami.Theme` + `Kirigami.Units`. Must implement:

**Functions:**
- `venueSubTypeTagColor(type)` → color for venue sub-type flag chips
- `vegTypeColor(type)` → vegan=#97BF0F green, vegetarian=orange, omnivore=red
- `iconFor(type)` → `{iconString, fontFamily}` object for font-glyph icons
  Types: "answer", "favorite", "favorite-o", "home", "filter", "vegan", "my_location",
  "location", "cover-location", "coffee", "map", "list", "shopping", "about", "schedule",
  "details", "accessible", "more_vert", "date_range"
  **Open decision**: Keep Material Icons font glyphs, or switch to FreeDesktop icon names
  for `Kirigami.Icon`?
- `dp(x)` → map to `Kirigami.Units.gridUnit` scaling

**All colors, sizes, and layout properties** from the Felgo Theme must be present (see
`components-platform/felgo/qml/Theme.qml` lines 1–210 for the full list).

#### Platform

```qml
pragma Singleton
import QtQml
QtObject {
    readonly property bool isKirigami: true
    readonly property bool isSailfish: false
    readonly property bool isFelgo: false
    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isIos: Qt.platform.os === "ios"
    readonly property bool isMacOS: Qt.platform.os === "osx"
    readonly property bool isLinux: Qt.platform.os === "linux"
}
```

Note: Shared QML has ~20 uses of `Platform.isSailfish` / `Platform.isFelgo` (mostly in
`AboutBerlinVegan.qml`, `VenueDetails.qml`, `VenueDescriptionHeader.qml`). Gradually migrate
to Theme properties (many already have been: `Theme.headerBarOverlapsImage`, etc.).

### Implementation Phases

**Phase 1 — Shell** (get the app launching with Kirigami drawer navigation):
1. `CMakeLists.txt` for Kirigami platform module
2. `ApplicationWindow`, `Page`, `NavigationMenu`, `MenuItem`, `ActionMenuItem`
3. `Theme` singleton mapping all ~50 properties to Kirigami.Theme/Units
4. `Platform` singleton
5. Minimal stubs for all other components

**Phase 2 — Content** (venue list and detail pages rendering):
6. `Label`, `ListItem`, `ListView`, `Flickable`, `ScrollDecorator`
7. `SearchField`, `DetailItem`, `SectionHeader`, `Separator`, `PageHeader`
8. `Button`, `BusyIndicator`

**Phase 3 — Input** (filter page working):
9. `TextSwitch`, `ValueSelector`, `IconButton`
10. `CustomOpenTextSwitch` (complex — time/date pickers)

**Phase 4 — Map** (MapLibre integration):
11. `Map` → QtLocation.Map + MapLibre plugin + parklibre gesture code
12. `MapReCenterButton`
13. QMapLibre git submodule + build setup

**Phase 5 — Polish**:
14. `Image` (fullscreen viewer), `OpacityRampEffect`
15. Cover stubs

### Build System Changes

New `components-platform/kirigami/CMakeLists.txt`:
```cmake
find_package(KF6 REQUIRED COMPONENTS Kirigami)
find_package(QMapLibre REQUIRED COMPONENTS Core Location)

qt_add_qml_module(BerlinVeganPlatformKirigami
    STATIC
    URI BerlinVegan.components.platform
    VERSION 1.0
    IMPORTS org.kde.kirigami
    QML_FILES
        qml/ApplicationWindow.qml
        qml/Page.qml
        # ... all components
    NO_RESOURCE_TARGET_PATH
)
```

Root CMakeLists.txt additions:
- CMake option: `-DBVAPP_PLATFORM=felgo` (default) vs `-DBVAPP_PLATFORM=kirigami`
- Conditional `add_subdirectory(components-platform/kirigami)` or `components-platform/felgo`
- `find_package(QMapLibre REQUIRED COMPONENTS Core Location)` when Kirigami
- `QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL)` in main.cpp (MapLibre req)

QMapLibre setup (from parklibre's `scripts/setup-qt.sh`):
```bash
# Git submodule at extern/qmaplibre/ → maplibre-native-qt
cmake -B extern/qmaplibre/build -S extern/qmaplibre -G Ninja \
  -DCMAKE_PREFIX_PATH="$QT_DIR" \
  -DCMAKE_INSTALL_PREFIX="$QT_DIR" \
  -DMLN_QT_WITH_WIDGETS=OFF \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build extern/qmaplibre/build
cmake --install extern/qmaplibre/build
```

Android: bundle the geoservices plugin:
```cmake
if(ANDROID)
    set(_maplibre_geo_plugin
        "${QT6_INSTALL_PREFIX}/plugins/geoservices/libplugins_geoservices_qtgeoservices_maplibre_${CMAKE_ANDROID_ARCH_ABI}.so")
    set_target_properties(app PROPERTIES
        QT_ANDROID_EXTRA_LIBS "${_maplibre_geo_plugin}")
endif()
```

---

## 9. parklibre MapLibre Reference

parklibre (`/Users/michael.voigt/devel/parklibre/`) is the reference implementation for
Qt6 + MapLibre + plain QtQuick.Controls. Key patterns to reuse directly:

### Integration approach
- **Git submodule**: `extern/qmaplibre/` → `https://github.com/maplibre/maplibre-native-qt.git`
- **Installed into Qt prefix** via `cmake --install` with `-DCMAKE_INSTALL_PREFIX="$QT_DIR"`
- **Found via**: `find_package(QMapLibre REQUIRED COMPONENTS Core Location)`
- **Used as Qt Location plugin**: standard `QL.Map` with `plugin: "maplibre"` — NOT a custom
  widget, just the Qt Location API backed by MapLibre

### QML Map configuration
```qml
import QtLocation as QL
QL.Map {
    plugin: Plugin {
        name: "maplibre"
        parameters: [
            PluginParameter {
                name: "maplibre.map.styles"
                value: "https://tiles.openfreemap.org/styles/liberty"
            }
        ]
    }
}
```
Tile source: **OpenFreeMap liberty style** — free, no API key required.

### Gesture handling (ParkMap.qml) — reuse directly
- **PinchHandler**: pinch-to-zoom with inertia, `map.alignCoordinateToPoint()` for focal zoom
- **DragHandler** (pan + hold-drag-zoom): flick inertia via Vector3dAnimation (500ms,
  Easing.OutQuad); hold-drag-zoom by detecting `Date.now() - lastTapTime < 300ms`
- **TapHandler** (double-tap zoom): NumberAnimation +1 level (350ms, Easing.OutCubic)
- **WheelHandler**: scroll-to-zoom for mouse/trackpad
- `interactive` property disables all gestures when overlays are open

### Markers
```qml
MapItemView {
    parent: mapView.map
    model: viewModel.visibleItems  // ViewportFilterModel proxy
    delegate: MapQuickItem {
        coordinate: QtPositioning.coordinate(latitude, longitude)
        sourceItem: Rectangle { /* circle + icon + TapHandler */ }
    }
}
```
Viewport filtering: `ViewportFilterModel` (QSortFilterProxyModel) filters by
`QGeoRectangle::contains()`, updated via a 100ms debounce timer on center/zoom changes.

### User location dot
```qml
MapQuickItem {
    parent: mapView.map
    visible: locationViewModel.hasLocation
    coordinate: locationViewModel.currentLocation
    sourceItem: Rectangle { width: 24; height: 24; radius: 12; color: "#2196F3" }
}
```

### Critical main.cpp requirement
```cpp
// MapLibre v3.x requires OpenGL — MUST be set before QGuiApplication
QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
```

### Key parklibre files
| File | Purpose |
|------|---------|
| `CMakeLists.txt` | `find_package(QMapLibre)`, linking, Android bundling |
| `.gitmodules` | QMapLibre submodule reference |
| `scripts/setup-qt.sh` | Qt + QMapLibre build/install script |
| `src/main.cpp` | OpenGL requirement, Material style setup |
| `qml/MapScreen.qml` | Map plugin config, markers, user location, bearing/tilt lock |
| `qml/components/ParkMap.qml` | Full gesture handling (pin, drag, tap, wheel, tilt) |
| `src/models/viewportfiltermodel.h/.cpp` | Viewport-based proxy filter |

---

## 10. Key Files Reference

### Berlin Vegan App (`/Users/michael.voigt/devel/BVApp/harbour-Berlin-Vegan/`)

**Platform layer (Felgo) — actively maintained:**
- `components-platform/felgo/qml/Map.qml` — AppMap wrapper with all gestures (123 lines)
- `components-platform/felgo/qml/NavigationMenu.qml` — drawer wrapper (16 lines)
- `components-platform/felgo/qml/ApplicationWindow.qml` — Felgo App root (47 lines)
- `components-platform/felgo/qml/Theme.qml` — design tokens singleton (210 lines)
- `components-platform/felgo/qml/MenuItem.qml` — NavigationItem wrapper (65 lines)
- `components-platform/felgo/CMakeLists.txt` — Felgo platform module build

**Platform layer (Sailfish) — active, invest where effort is justifiable:**
- `components-platform/sailfish/` — 32 Silica wrapper QML files + hand-written `qmldir`
- Stale: missing `MapBearingLock`, `ReverseGeocoder`, `OsmOpeningHoursParser` in
  `BerlinVegan.pro`. Needs updating before the Sailfish build can compile again.

**Shared QML pages:**
- `qml/harbour-berlin-vegan.qml` — root ApplicationWindow + NavigationMenu + data loading
- `qml/pages/VenueList.qml` — main venue list with search, uses `pageStack.pushAttached()`
- `qml/pages/VenueDescription.qml` — venue detail page (Flickable-based)
- `qml/pages/VenueFilterSettings.qml` — filter page with ~15 TextSwitch + ValueSelector
- `qml/pages/VenueMapOverviewPage.qml` — map page with venue markers
- `qml/pages/AboutBerlinVegan.qml` — about page (most `Platform.isFelgo/isSailfish` uses)

**Shared QML components:**
- `qml/components/VenueListItem.qml` — list delegate (uses `BVApp.ListItem`)
- `qml/components/VenueDetails.qml` — detail content (12 `DetailItem` rows)
- `qml/components/VenueDescriptionHeader.qml` — photo swiper + header
- `qml/components/VenueMapWidget.qml` — inline mini-map on detail page
- `qml/components/IconToolBar.qml` — call/fav/website action bar
- `qml/components/VenueSubTypeTagCloud.qml` — tag chips using `Theme.venueSubTypeTagColor()`
- `components-ui/qml/CollapsibleItem.qml` — uses `BVApp.OpacityRampEffect`
- `components-ui/qml/SwipeView.qml` — reusable swipe view

**C++ sources:**
- `src/VenueModel.h/.cpp` — QStandardItemModel, macro-generated roles, OSM dedup
- `src/VenueSortFilterProxyModel.h/.cpp` — OR/AND filters, distance sort, deferred invalidation
- `src/VenueHandle.h` — QML property proxy per venue
- `src/OSMProvider.h/.cpp` — Overpass API client (QML_SINGLETON)
- `src/OsmOpeningHoursParser.h/.cpp` — "Mo-Fr 09:00-18:00" parser (~90% coverage)
- `src/VenueDataLoader.h/.cpp` — berlin-vegan.de JSON loader (QML_SINGLETON)
- `src/FavoritesManager.h/.cpp` — QSettings persistence (QML_SINGLETON)
- `src/OpeningHoursAlgorithms.h/.cpp` — opening hours + Berlin holidays
- `src/ReverseGeocoder.h/.cpp` — Nominatim street lookup
- `src/MapBearingLock.h` — QML_ELEMENT for synchronous bearing reset
- `src/TruncationMode.h` — enum (QML_UNCREATABLE)
- `src/main.cpp` — entry point (minimal; no qmlRegisterType calls)

**Build:**
- `CMakeLists.txt` — Qt6/Felgo CMake build (root)
- `BerlinVegan.pro` — Qt5/Sailfish QMake build (stale — needs C++ class updates)
- `android/build.gradle` — AGP 8.0.2, compileSdk 34
- `android/AndroidManifest.xml` — ACCESS_FINE_LOCATION permission
- `build-android/` — CMake Android build directory (pre-configured)

**Tests:**
- `tests/tst_osm_opening_hours.cpp` — 21 tests
- `tests/tst_opening_hours_algorithms.cpp` — 18 tests
- `tests/tst_deduplication.cpp` — 11 tests
- Build: `ninja -C build tst_osm_opening_hours tst_opening_hours_algorithms tst_deduplication`

**Translations:**
- `translations/harbour-berlin-vegan-{de,en,nl}.ts`
- Pattern: `qsTrId("id-descriptive-name")` with `//%` source comments
- Build: `qt_add_translations` with `LRELEASE_OPTIONS -idbased`

---

## 11. Open Items & Next Steps

### Immediate (complete the current Felgo/OSM round first)
1. **Small redesign improvements** on the Felgo build — user to specify which ones
2. **Confirm hold-drag zoom** works correctly on device (user hasn't verified yet)
3. **Run full test suite** — verify all 50 tests pass after recent changes
4. **PR / merge preparation** — `feature/application_revamp` → `main`

### Sailfish build restoration
5. Update `BerlinVegan.pro` to include new C++ sources:
   - `src/MapBearingLock.h` (header-only QML_ELEMENT — may not need .cpp entry)
   - `src/ReverseGeocoder.h/.cpp`
   - `src/OsmOpeningHoursParser.h/.cpp`
   - Any other sources added since the .pro file was last updated
6. Verify `components-platform/sailfish/` QML still works with updated shared QML pages
7. **Evaluate**: migrate Sailfish build from QMake to CMake? (SDK 3.3+ supports it)
   - Pro: unified build system, same toolchain knowledge
   - Con: Qt5 CMake patterns differ from Qt6 (`qt_add_qml_module` is Qt6-only)
   - `sailfishapp` via `pkg_check_modules(sailfishapp REQUIRED sailfishapp)` in CMake

### Kirigami platform layer (after Felgo round is done)
8. Phase 1: Shell — `ApplicationWindow`, `Page`, `NavigationMenu`, `MenuItem`, `Theme`,
   `Platform`; CMake module; minimal stubs for all other components
9. Phase 2: Content — `Label`, `ListItem`, `ListView`, `Flickable`, `SearchField`,
   `DetailItem`, `SectionHeader`, `Separator`, `Button`, `BusyIndicator`
10. Phase 3: Input — `TextSwitch`, `ValueSelector`, `IconButton`, `CustomOpenTextSwitch`
11. Phase 4: Map — `Map` (MapLibre from parklibre), `MapReCenterButton`, QMapLibre submodule
12. Phase 5: Polish — `Image` viewer, `OpacityRampEffect`, cover stubs

### Open design decisions (resolve when implementing Kirigami layer)
- **Icon strategy**: Keep Material Icons font glyphs (`iconFor()` returns `{iconString, fontFamily}`)
  or switch to FreeDesktop icon names for `Kirigami.Icon`?
- **`pushAttached` replacement**: Kirigami multi-column or toolbar action?
- **Time/date pickers**: `Qt.labs.platform` dialogs or custom QML drum rollers?
- **Viewport filtering**: Port parklibre's `ViewportFilterModel` C++ for Berlin Vegan maps?

### Strategic (longer term)
- **Evaluate Felgo necessity**: Could Kirigami eventually serve iOS/Google Play too?
  (Kirigami works on Android; iOS AppStore compliance is the main blocker)
- **Sailfish CHUM packaging**: When Kirigami layer is ready, package for CHUM
- **QMapLibre on Sailfish CHUM**: Needs QMapLibre built against CHUM's Qt6 packages
- **Monitor decon's Silica-for-Qt6 port**: If published, evaluate vs. Kirigami approach
- **Monitor Jolla Qt6 progress**: J2 launch, CRA compliance decisions, community Qt6 PRs

---

## 12. Key URLs

| Topic | URL |
|-------|-----|
| Sailfish forum | https://forum.sailfishos.org |
| Upgrading Silica to Qt6 | https://forum.sailfishos.org/t/upgrading-silica-to-qt6/26712 |
| JoshStrobl on two Silica versions | https://forum.sailfishos.org/t/android-enshittification-process-lets-promote-sailfish-os/24976/31 |
| Jolla Phone J2 update | https://forum.sailfishos.org/t/jolla-phone-update-lights-on-technical-bits-and-the-schedule/27821 |
| Sailfish 5.0.0.77 release notes | https://forum.sailfishos.org/t/release-notes-tampella-5-0-0-77/28520 |
| Community News April 2026 | https://forum.sailfishos.org/t/sailfish-community-news-2nd-april-2026-final-payment/28838 |
| MWC Barcelona 2026 | https://forum.sailfishos.org/t/sailfish-community-news-5th-march-2026-mwc-barcelona-2026/28114 |
| FOSDEM 2026 debrief | https://forum.sailfishos.org/t/sailfish-community-news-february-5th-2026-fosdem-2026-debrief/27554 |
| EU CRA regulation | https://eur-lex.europa.eu/eli/reg/2024/2847 |
| Qt licensing change | https://www.qt.io/blog/2016/01/13/new-agreement-with-the-kde-free-qt-foundation |
| Aurora developer portal | https://developer.auroraos.ru |
| Sailfish CMake sample | https://github.com/sailfishos/cmakesample |
| Sailfish SDK build docs | https://docs.sailfishos.org/Develop/Apps/Tutorials/Building_packages_-_advanced_techniques/ |
| parklibre (reference app) | `/Users/michael.voigt/devel/parklibre/` |
| Felgo SDK | `/Users/michael.voigt/Felgo/Felgo/macos/` |
