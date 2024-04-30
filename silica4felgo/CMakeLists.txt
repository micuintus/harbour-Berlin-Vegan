
file(GLOB_RECURSE Silica4FelgoQml RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.js qml/*.qml)

qt_add_qml_module(Silica4Felgo
    STATIC
    URI Sailfish.Silica
    VERSION 1.0
    PLUGIN_TARGET Silica4FelgoPlugin
    QML_FILES ${Silica4FelgoQml}
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Sailfish/Silica
    SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/TruncationMode.h
    IMPORTS BerlinVegan.components.platform
)

target_include_directories(Silica4Felgo
    PUBLIC
    src
)
