# CONFIGURE_DEPENDS: without it the list is frozen at configure time, so adding
# a QML file leaves every existing build directory silently missing the type.
file(GLOB_RECURSE PlatformQml CONFIGURE_DEPENDS
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.js qml/*.qml)
set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(qml/Platform.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(BerlinVeganPlatform
    STATIC
    URI BerlinVegan.components.platform
    VERSION 1.0
    PLUGIN_TARGET BerlinVeganPlatformPlugin
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/BerlinVegan/components/platform
    IMPORTS
        Felgo
    QML_FILES ${PlatformQml}
)
