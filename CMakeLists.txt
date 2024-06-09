cmake_minimum_required(VERSION 3.16)

project(harbour-berlin-vegan VERSION 3.7.0 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)


find_package(Felgo REQUIRED)
find_package(Qt6 COMPONENTS Positioning Location REQUIRED)

# Define version macro
add_compile_definitions(APP_VERSION="${PROJECT_VERSION}")

set(PRODUCT_IDENTIFIER "org.berlin_vegan.bvapp")
set(PRODUCT_VERSION_NAME APP_VERSION)
set(PRODUCT_VERSION_CODE 3)
set(PRODUCT_LICENSE_KEY "")

# Find all QML/JS files for the QML compiler:
file(GLOB_RECURSE QmlFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/harbour-berlin-vegan.qml qml/pages/*.qml qml/cover/*.qml)

# Find all non-QML/JS files in the qml and assets folder to add as resources:
file(GLOB_RECURSE AssetsFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/pages/* images/* icons/*)

list(REMOVE_ITEM AssetsFiles ${QmlFiles})


set(SOURCES
    src/BerlinVegan.cpp
    src/FileIO.cpp
    src/VenueModel.cpp
    src/VenueSortFilterProxyModel.cpp
)

set(HEADERS
    src/VenueModel.h
    src/VenueHandle.h
    src/VenueSortFilterProxyModel.h
    src/FileIO.h
    src/OpeningHoursAlgorithms.h
)


qt_add_executable(harbour-berlin-vegan ${SOURCES} ${HEADERS} ${QmlFiles} resources.qrc) #$ ${AssetsFiles} ${GenericQml} ${GenericRes} ${PlatformQml} ${PlatformRes})

felgo_configure_executable(harbour-berlin-vegan)

add_subdirectory(silica4felgo)
add_subdirectory(components-felgo)
add_subdirectory(components-generic)

qt_add_qml_module(berlin-vegan-qml
    URI harbor.berlin.vegan
    VERSION 1.0
    QML_FILES ${QmlFiles}
    PLUGIN_TARGET berlin-vegan-qml-plugin
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/harbor/berlin/vegan
    IMPORTS
        BerlinVegan.components.platform
        BerlinVegan.components.generic
    RESOURCE_PREFIX /
)

target_compile_definitions(harbour-berlin-vegan PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(harbour-berlin-vegan PRIVATE  Qt6::Positioning Qt6::Location berlin-vegan-qml Silica4Felgo Silica4FelgoPlugin BerlinVeganPlatformPlugin BerlinVeganGenericPlugin Felgo)
