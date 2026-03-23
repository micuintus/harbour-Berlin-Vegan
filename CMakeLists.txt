cmake_minimum_required(VERSION 3.21)

project(harbour-berlin-vegan VERSION 3.7.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Felgo REQUIRED)
find_package(Qt6 COMPONENTS Core Qml Quick Network Positioning Location LinguistTools REQUIRED)

qt_standard_project_setup(
    I18N_TRANSLATED_LANGUAGES de en nl
    I18N_SOURCE_LANGUAGE en
)

add_compile_definitions(APP_VERSION="${PROJECT_VERSION}")

set(PRODUCT_IDENTIFIER "org.berlin_vegan.bvapp")
set(PRODUCT_VERSION_NAME APP_VERSION)
set(PRODUCT_VERSION_CODE 3)
set(PRODUCT_LICENSE_KEY "")

# --- Executable ---

qt_add_executable(harbour-berlin-vegan src/main.cpp)

if(APPLE AND NOT IOS)
    set_target_properties(harbour-berlin-vegan PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/macos/Info.plist"
    )
endif()

felgo_configure_executable(harbour-berlin-vegan)

# --- Sub-modules ---

add_subdirectory(components-platform/felgo)
add_subdirectory(components-ui)

# --- Main QML module: C++ types + pages + venue components ---

set_source_files_properties(qml/components/VenueSubTypeDefinitions.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(harbour-berlin-vegan
    URI harbour.berlin.vegan
    VERSION 1.0
    NO_RESOURCE_TARGET_PATH
    SOURCES
        src/VenueModel.h src/VenueModel.cpp
        src/VenueSortFilterProxyModel.h src/VenueSortFilterProxyModel.cpp
        src/VenueHandle.h
        src/FavoritesManager.h src/FavoritesManager.cpp
        src/VenueDataLoader.h src/VenueDataLoader.cpp
        src/TruncationMode.h
        src/OSMProvider.h src/OSMProvider.cpp
        src/OsmOpeningHoursParser.h src/OsmOpeningHoursParser.cpp
        src/OpeningHoursAlgorithms.h src/OpeningHoursAlgorithms.cpp
    QML_FILES
        qml/harbour-berlin-vegan.qml
        qml/pages/VenueList.qml
        qml/pages/VenueDescription.qml
        qml/pages/VenueFilterSettings.qml
        qml/pages/VenueMapOverviewPage.qml
        qml/pages/VenueMapWidget.qml
        qml/pages/OSMVenueList.qml
        qml/pages/about/AboutBerlinVegan.qml
        qml/pages/about/LicenseViewer.qml
        qml/pages/about/ThirdPartySoftware.qml
        qml/cover/CoverPage.qml
        qml/components/VenueListItem.qml
        qml/components/VenueDetails.qml
        qml/components/VenueDescriptionHeader.qml
        qml/components/IconToolBar.qml
        qml/components/VenueSubTypeTagCloud.qml
        qml/components/VenueSubTypeDefinition.qml
        qml/components/VenueSubTypeDefinitions.qml
        qml/components/VenueDescriptionAlgorithms.js
        qml/components/tinycolor.js
    IMPORTS
        BerlinVegan.components.platform
        BerlinVegan.components.ui
)

# --- Non-QML resources ---

qt_add_resources(harbour-berlin-vegan "assets"
    PREFIX "/"
    FILES
        qml/config.json
        icons/MaterialIcons-Regular.ttf
        icons/icomoon.ttf
        images/Platzhalter_v2_mitSchriftzug.jpg
        images/Platzhalter_v2_mitSchriftzug_alpha.png
        images/Platzhalter_v2_mitSchriftzug_header.jpg
)

qt_add_resources(harbour-berlin-vegan "bundled_data"
    PREFIX "/"
    FILES
        qml/pages/GastroLocations.json
        qml/pages/ShoppingLocations.json
)

qt_add_resources(harbour-berlin-vegan "licenses"
    PREFIX "/"
    FILES
        qml/pages/about/BerlinVegan.svg
        qml/pages/about/CC-by-nc-legalcode.txt
        qml/pages/about/LICENSE
        qml/pages/about/LICENSE.Cutehacks
        qml/pages/about/LICENSE.qml-utils
        qml/pages/about/LICENSE.YTPlayer
        qml/pages/about/LICENSE.TinyColor
        qml/pages/about/LICENSE.FelgoComponentShowcase
)

qt_add_translations(harbour-berlin-vegan
    TS_FILES
        translations/harbour-berlin-vegan-de.ts
        translations/harbour-berlin-vegan-en.ts
        translations/harbour-berlin-vegan-nl.ts
    RESOURCE_PREFIX "/translations"
    LRELEASE_OPTIONS -idbased
)

# --- Link ---

target_compile_definitions(harbour-berlin-vegan
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_include_directories(harbour-berlin-vegan PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_link_libraries(harbour-berlin-vegan PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Network
    Qt6::Positioning
    Qt6::Location
    Felgo
)
