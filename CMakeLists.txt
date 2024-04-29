cmake_minimum_required(VERSION 3.16)

project(harbour-berlin-vegan VERSION 3.6.3 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)



find_package(Felgo REQUIRED)
find_package(Qt6 COMPONENTS Positioning Location REQUIRED)

# Define version macro
add_compile_definitions(APP_VERSION="${PROJECT_VERSION}")



set(PRODUCT_IDENTIFIER "harbour.berlin.vegan")
set(PRODUCT_VERSION_NAME APP_VERSION)
set(PRODUCT_VERSION_CODE 3)
set(PRODUCT_LICENSE_KEY "")

# Find all QML/JS files for the QML compiler:
file(GLOB_RECURSE QmlFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/harbour-berlin-vegan.qml qml/pages/*.qml qml/cover/*.qml)

# Find all non-QML/JS files in the qml and assets folder to add as resources:
file(GLOB_RECURSE AssetsFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/pages/* images/* icons/* resources.qrc)

file(GLOB_RECURSE PlatformQml RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/components-felgo/*.js qml/components-felgo/*.qml)
file(GLOB_RECURSE GenericQml RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/components-generic/*.js qml/components-generic/*.qml)

list(REMOVE_ITEM PlatformRes ${PlatformQml})
list(REMOVE_ITEM GenericRes ${GenericQml})

 message(WARNING ${PlatformQml} )


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
    src/TruncationMode.h
)

qt_add_executable(harbour-berlin-vegan ${SOURCES} ${HEADERS} ${QmlFiles}) #$ ${AssetsFiles} ${GenericQml} ${GenericRes} ${PlatformQml} ${PlatformRes})


 felgo_configure_executable(harbour-berlin-vegan)

 add_subdirectory(src/Sailfish/Silica)

 # Deploy resources to build folder/package directly - comment for publishing
 deploy_resources("${QmlFiles};${AssetsFiles}; ${GenericQml}; ${GenericRes}; ${PlatformQml}; ${PlatformRes}")


 qt_add_qml_module(berlin-vegan-qml
    URI harbor.berlin.vegan
    VERSION 1.0
    QML_FILES ${QmlFiles}
    RESOURCES ${AssetsFiles}
    PLUGIN_TARGET berlin-vegan-qml-plugin
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/harbor/berlin/vegan
    RESOURCE_PREFIX /
 )

qt_add_qml_module(berlin-vegan-generic
    URI BerlinVegan.components.generic
    VERSION 1.0
    QML_FILES ${GenericQml}
    PLUGIN_TARGET berlin-vegan-generic-plugin
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/BerlinVegan/components/generic
   # RESOURCE_PREFIX /qml/components-generic/
)

qt_add_qml_module(berlin-vegan-platform
    URI BerlinVegan.components.platform
    VERSION 1.0
    QML_FILES ${PlatformQml}
    PLUGIN_TARGET berlin-vegan-platform-plugin
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/BerlinVegan/components/platform
   # RESOURCE_PREFIX /qml/components-platform
)



qt_import_plugins(harbour-berlin-vegan
    INCLUDE berlin-vegan-qml
    INCLUDE silica4felgo
    INCLUDE berlin-vegan-platform
    INCLUDE berlin-vegan-generic
)

 target_compile_definitions(harbour-berlin-vegan PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
 target_link_libraries(harbour-berlin-vegan PUBLIC  Qt6::Positioning Qt6::Location berlin-vegan-qml Silica4FelgoPlugin berlin-vegan-platform berlin-vegan-generic Felgo)
