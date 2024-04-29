

file(GLOB_RECURSE Silica4FelgoQml RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.js *.qml)

message(WARNING ${Silica4FelgoQml})

qt_add_library(Silica4Felgo STATIC)

qt_add_qml_module(Silica4Felgo
    PLUGIN_TARGET Silica4FelgoPlugin
    URI Sailfish.Silica
    VERSION 1.0
    QML_FILES ${Silica4FelgoQml}
)
