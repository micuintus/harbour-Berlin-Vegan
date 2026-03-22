file(GLOB_RECURSE UiQml RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.js qml/*.qml)

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
