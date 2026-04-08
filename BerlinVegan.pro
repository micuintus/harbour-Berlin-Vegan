# SailfishOS build (QMake). For Felgo/Qt6 use CMakeLists.txt.
TARGET = harbour-berlin-vegan

VERSION="4.0.0"

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

QT += positioning location network

CONFIG += c++17

SOURCES += src/main.cpp \
           src/FavoritesManager.cpp \
           src/OpeningHoursAlgorithms.cpp \
           src/VenueDataLoader.cpp \
           src/VenueModel.cpp \
           src/VenueSortFilterProxyModel.cpp

HEADERS += src/FavoritesManager.h \
           src/VenueDataLoader.h \
           src/VenueModel.h \
           src/VenueHandle.h \
           src/VenueSortFilterProxyModel.h \
           src/OpeningHoursAlgorithms.h \
           src/TruncationMode.h

# Sailfish-specific resources will need updating when
# components-platform/sailfish is integrated with QMake.
# For now this .pro file is maintained for reference.

packagesExist(sailfishapp) {
DEFINES += Q_OS_SAILFISH

CONFIG += sailfishapp
CONFIG += sailfishapp_no_deploy_qml

CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased
}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
    QMAKE_ASSET_CATALOGS += $$PWD/ios/Images.xcassets
    QMAKE_TARGET_BUNDLE_PREFIX = "org.berlin-vegan"
    QMAKE_BUNDLE = "bvapp"
}

TRANSLATIONS += translations/harbour-berlin-vegan-de.ts \
                translations/harbour-berlin-vegan-en.ts \
                translations/harbour-berlin-vegan-nl.ts
