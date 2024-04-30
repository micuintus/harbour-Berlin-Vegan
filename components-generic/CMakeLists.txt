
file(GLOB_RECURSE GenericQml RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.js qml/*.qml)

set_source_files_properties(qml/VenueSubTypeDefinitions.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(BerlinVeganGeneric
    STATIC
    URI BerlinVegan.components.generic
    VERSION 1.0
    PLUGIN_TARGET BerlinVeganGenericPlugin
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/BerlinVegan/components/generic
    IMPORTS BerlinVegan.components.platform
    QML_FILES ${GenericQml}
)
