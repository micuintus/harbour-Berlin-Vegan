cmake_minimum_required(VERSION 3.21)

project(harbour-berlin-vegan VERSION 4.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# --- Platform selection ---

set(BV_PLATFORM "felgo" CACHE STRING "Platform backend: felgo or kirigami")

# Off-screen render/introspection driver used to score platform-layer fidelity.
# Never enable for a shipping build: it hijacks the event loop and exits.
option(BV_HARNESS "Build the render-fidelity harness into the executable" OFF)

# Vector maps via the Qt Location "maplibre" plugin. Optional: without it the
# platform layer falls back to the raster osm provider, which is also the only
# option on Sailfish.
find_package(QMapLibre QUIET COMPONENTS Core Location)

if(BV_PLATFORM STREQUAL "kirigami")
    find_package(Qt6 COMPONENTS Core Qml Quick QuickControls2 Widgets Network Positioning Location Svg Concurrent LinguistTools REQUIRED)
    find_package(KF6Kirigami REQUIRED)
    find_package(ECM REQUIRED NO_MODULE)
    list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
else()
    find_package(Felgo REQUIRED)
    find_package(Qt6 COMPONENTS Core Qml Quick Network Positioning Location LinguistTools REQUIRED)
endif()

qt_standard_project_setup(
    I18N_TRANSLATED_LANGUAGES de en nl
    I18N_SOURCE_LANGUAGE en
)

add_compile_definitions(APP_VERSION="${PROJECT_VERSION}")

set(PRODUCT_IDENTIFIER "org.berlin_vegan.bvapp")
set(PRODUCT_VERSION_NAME APP_VERSION)
set(PRODUCT_VERSION_CODE 4)
set(PRODUCT_LICENSE_KEY "")

# --- Executable ---

qt_add_executable(harbour-berlin-vegan src/main.cpp)

if(BV_HARNESS)
    target_sources(harbour-berlin-vegan PRIVATE
        tools/harness/RenderHarness.cpp tools/harness/RenderHarness.h)
    target_include_directories(harbour-berlin-vegan PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/tools/harness)
    target_compile_definitions(harbour-berlin-vegan PRIVATE BV_HARNESS)
endif()

if(APPLE AND NOT IOS)
    set_target_properties(harbour-berlin-vegan PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/macos/Info.plist"
    )
endif()

if(BV_PLATFORM STREQUAL "felgo")
    felgo_configure_executable(harbour-berlin-vegan)
elseif(BV_PLATFORM STREQUAL "kirigami")
    target_compile_definitions(harbour-berlin-vegan PRIVATE BV_KIRIGAMI)
endif()

# --- Android configuration (Kirigami builds) ---

if(ANDROID AND BV_PLATFORM STREQUAL "kirigami")
    include(FetchContent)
    FetchContent_Declare(android_openssl
        DOWNLOAD_EXTRACT_TIMESTAMP true
        URL https://github.com/KDAB/android_openssl/archive/b71f1470962019bd89534a2919f5925f93bc5779.zip)
    FetchContent_MakeAvailable(android_openssl)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)
    add_android_openssl_libraries(harbour-berlin-vegan)

    math(EXPR _version_code
        "${PROJECT_VERSION_MAJOR} * 10000 + ${PROJECT_VERSION_MINOR} * 100 + ${PROJECT_VERSION_PATCH}")

    # KF6_ANDROID_PREFIX must point to a KF6 installation cross-compiled for Android.
    # Example: cmake -DKF6_ANDROID_PREFIX=/opt/kf6-android ...
    if(DEFINED KF6_ANDROID_PREFIX)
        set_target_properties(harbour-berlin-vegan PROPERTIES
            # Let androiddeployqt find KF6 QML modules
            QT_QML_IMPORT_PATH "${KF6_ANDROID_PREFIX}/lib/qml"
            # Bundle the Kirigami shared library
            QT_ANDROID_EXTRA_LIBS "${KF6_ANDROID_PREFIX}/lib/libKF6Kirigami.so"
        )
    endif()

    set_target_properties(harbour-berlin-vegan PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
        QT_ANDROID_PACKAGE_NAME "${PRODUCT_IDENTIFIER}"
        QT_ANDROID_VERSION_CODE "${_version_code}"
        QT_ANDROID_VERSION_NAME "${PROJECT_VERSION}"
    )
endif()

# --- Sub-modules ---

add_subdirectory(components-platform/${BV_PLATFORM})
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
        src/ReverseGeocoder.h src/ReverseGeocoder.cpp
        src/NominatimService.h src/NominatimService.cpp
        src/OsmOpeningHoursParser.h src/OsmOpeningHoursParser.cpp
        src/OpeningHoursAlgorithms.h src/OpeningHoursAlgorithms.cpp
        src/MapBearingLock.h
    QML_FILES
        qml/harbour-berlin-vegan.qml
        qml/pages/VenueList.qml
        qml/pages/VenueDescription.qml
        qml/pages/VenueFilterSettings.qml
        qml/pages/VenueMapOverviewPage.qml
        qml/pages/VenueMapWidget.qml
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
        qml/components/AddressSearchField.qml
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

# --- Tests ---

add_subdirectory(tests)

# --- Link ---

target_compile_definitions(harbour-berlin-vegan
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_include_directories(harbour-berlin-vegan PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

if(QMapLibre_FOUND)
    target_link_libraries(harbour-berlin-vegan PRIVATE QMapLibre::Core QMapLibre::Location)
    # The Felgo SDK bundles its own QMapLibre 3 framework, and its headers are
    # otherwise found first, so <QMapLibre/Utils> resolves to a version without
    # supportedRendererType. Force our framework dir ahead of the SDK's.
    get_target_property(_mln_cfg QMapLibre::Core IMPORTED_LOCATION_RELEASE)
    if(APPLE AND _mln_cfg)
        get_filename_component(_mln_fw "${_mln_cfg}" DIRECTORY)   # .../QMapLibre.framework/Versions/A
        get_filename_component(_mln_fw "${_mln_fw}" DIRECTORY)    # .../Versions
        get_filename_component(_mln_fw "${_mln_fw}" DIRECTORY)    # .../QMapLibre.framework
        get_filename_component(_mln_fw "${_mln_fw}" DIRECTORY)    # .../lib
        target_compile_options(harbour-berlin-vegan BEFORE PRIVATE "-F${_mln_fw}")
        message(STATUS "QMapLibre framework dir prioritised: ${_mln_fw}")
    endif()
    target_compile_definitions(harbour-berlin-vegan PRIVATE BV_HAS_MAPLIBRE)
    if(APPLE)
        # Runs after Felgo's own deployment steps, which is the point: they
        # deploy the SDK's v3 plugin, and ours has to be the survivor.
        add_custom_command(TARGET harbour-berlin-vegan POST_BUILD
            COMMAND ${CMAKE_COMMAND}
                -DBUNDLE=$<TARGET_FILE_DIR:harbour-berlin-vegan>/../..
                -DQL_DIR=${QMapLibre_DIR}
                -DFELGO_LIB=${Felgo_DIR}/../..
                -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/BundleQMapLibre.cmake)
    endif()
    message(STATUS "QMapLibre found: vector maps enabled")
else()
    message(STATUS "QMapLibre not found: falling back to raster osm tiles")
endif()

target_link_libraries(harbour-berlin-vegan PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Network
    Qt6::Positioning
    Qt6::Location
)

if(BV_PLATFORM STREQUAL "kirigami")
    target_link_libraries(harbour-berlin-vegan PRIVATE
        Qt6::QuickControls2
        Qt6::Widgets
        Qt6::Svg
        Qt6::Concurrent
        KF6::Kirigami
    )
else()
    target_link_libraries(harbour-berlin-vegan PRIVATE Felgo)
endif()

# --- Deployment (Kirigami non-Android) ---

if(NOT ANDROID AND BV_PLATFORM STREQUAL "kirigami")
    install(TARGETS harbour-berlin-vegan
        BUNDLE  DESTINATION .
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    # Generates a deployment script that runs macdeployqt/windeployqt.
    # Run `cmake --install <builddir>` to produce a fully self-contained bundle
    # for distribution. During development, Qt is found via Homebrew and KF6
    # QML modules are bundled by the post-build steps below.
    qt_generate_deploy_qml_app_script(
        TARGET harbour-berlin-vegan
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
        DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    )
    install(SCRIPT ${deploy_script})

    # On macOS: bundle KF6 QML modules + dylibs so KF6_QML_IMPORT_PATH is not needed.
    # main.cpp already probes <AppDir>/../lib/qml at runtime.
    if(APPLE AND NOT IOS)
        # Derive KF6 install prefix from the cmake package location.
        # KF6Kirigami_DIR is typically <prefix>/lib/cmake/KF6Kirigami
        get_filename_component(_kf6_cmake_kf "${KF6Kirigami_DIR}" DIRECTORY)   # .../lib/cmake
        get_filename_component(_kf6_lib_dir  "${_kf6_cmake_kf}"   DIRECTORY)   # .../lib
        get_filename_component(_kf6_prefix   "${_kf6_lib_dir}"    DIRECTORY)   # <prefix>

        set(_bundle_dir "${CMAKE_CURRENT_BINARY_DIR}/harbour-berlin-vegan.app/Contents")

        # 1a. Remove stale QML filesystem artifacts from previous macdeployqt runs.
        #     Our QML is embedded as qrc:// resources; filesystem copies in
        #     Resources/qml/ take precedence and break JS imports if incomplete.
        add_custom_command(TARGET harbour-berlin-vegan POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E rm -rf
                "${_bundle_dir}/Resources/qml/BerlinVegan"
            COMMENT "Removing stale macdeployqt BerlinVegan QML artifacts"
            VERBATIM
        )

        # 1b. Copy KF6 QML modules (org/kde/kirigami etc.) into the bundle.
        #     main.cpp probes <AppDir>/../lib/qml at runtime, so no env var needed.
        add_custom_command(TARGET harbour-berlin-vegan POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "${_bundle_dir}/lib/qml"
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                "${_kf6_prefix}/lib/qml/org"
                "${_bundle_dir}/lib/qml/org"
            COMMENT "Bundling KF6 QML modules into .app"
            VERBATIM
        )

        # 2. Copy KF6 dylibs into bundle Frameworks.
        # KF6 libraries are named libKirigami*.dylib (no KF6 prefix).
        # We collect only the unversioned symlinks (*.dylib, not *.6.dylib or *.6.x.y.dylib)
        # so we don't duplicate files.
        file(GLOB _kf6_dylibs LIST_DIRECTORIES false "${_kf6_prefix}/lib/libKirigami*.dylib")
        if(_kf6_dylibs)
            add_custom_command(TARGET harbour-berlin-vegan POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory "${_bundle_dir}/Frameworks"
                VERBATIM
            )
            foreach(_dylib IN LISTS _kf6_dylibs)
                add_custom_command(TARGET harbour-berlin-vegan POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "${_dylib}" "${_bundle_dir}/Frameworks/"
                    VERBATIM
                )
            endforeach()
        else()
            message(WARNING "No libKirigami*.dylib found in ${_kf6_prefix}/lib — skipping dylib bundling")
        endif()

        # 3. Ensure the executable rpath includes the bundled Frameworks directory
        add_custom_command(TARGET harbour-berlin-vegan POST_BUILD
            COMMAND install_name_tool
                -add_rpath "@executable_path/../Frameworks"
                "$<TARGET_FILE:harbour-berlin-vegan>"
            COMMENT "Adding @executable_path/../Frameworks rpath to binary"
            VERBATIM
        )
    endif()
endif()
