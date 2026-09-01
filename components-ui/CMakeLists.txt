# CONFIGURE_DEPENDS: without it the list is frozen at configure time, so adding
# a QML file leaves every existing build directory silently missing the type.
file(GLOB_RECURSE UiQml CONFIGURE_DEPENDS
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.js qml/*.qml)

set_source_files_properties(qml/BrandTokens.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(BerlinVeganUi
    STATIC
    URI BerlinVegan.components.ui
    VERSION 1.0
    PLUGIN_TARGET BerlinVeganUiPlugin
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/BerlinVegan/components/ui
    IMPORTS
        BerlinVegan.components.platform
    QML_FILES ${UiQml}
)
