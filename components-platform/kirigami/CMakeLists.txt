file(GLOB_RECURSE PlatformQml RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.js qml/*.qml)
set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(qml/Platform.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(BerlinVeganPlatform
    STATIC
    URI BerlinVegan.components.platform
    VERSION 1.0
    PLUGIN_TARGET BerlinVeganPlatformPlugin
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/BerlinVegan/components/platform
    QML_FILES ${PlatformQml}
)

# Bundle platform-specific SVG icons that are not available in hicolor
# (the Qt built-in fallback theme). These are used by IconButton.qml via
# qrc:/icons/bv/<name>.svg when Breeze or another full KDE icon theme is
# not installed on the host system (e.g. macOS without breeze-icons).
qt_add_resources(BerlinVeganPlatform "kirigami_bundled_icons"
    PREFIX "/"
    FILES
        icons/starred-symbolic.svg
        icons/non-starred-symbolic.svg
        icons/go-home-symbolic.svg
)
