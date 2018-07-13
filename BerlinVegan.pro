# The name of your application
TARGET = harbour-berlin-vegan

VERSION="3.3.1alpha"

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

QT += positioning location

CONFIG += c++11

SOURCES += src/BerlinVegan.cpp \
           src/FileIO.cpp \
           src/VenueModel.cpp \
           src/VenueSortFilterProxyModel.cpp

HEADERS += src/VenueModel.h \
           src/VenueSortFilterProxyModel.h \
           src/FileIO.h \
           src/OpeningHoursAlgorithms.h \
           src/TruncationMode.h

RESOURCES += resources.qrc \
             qml/components-generic/resources-components-generic.qrc

packagesExist(sailfishapp) {
DEFINES += Q_OS_SAILFISH

CONFIG += sailfishapp
CONFIG += sailfishapp_no_deploy_qml

RESOURCES += qml/components-Sailfish/resources-components-Sailfish.qrc

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased

} else {
CONFIG    += v-play
RESOURCES += qml/Silica4v-play/resources-Silica4v-play.qrc \
             qml/components-v-play/resources-components-v-play.qrc
}

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST

    QMAKE_ASSET_CATALOGS += $$PWD/ios/Images.xcassets

    app_launch_images.files = $$PWD/ios/Launch.xib $$files($$PWD/ios/Splashscreen_1242x2208_mit-Schriftzug.jpg)
    QMAKE_BUNDLE_DATA += app_launch_images
}

TRANSLATIONS += translations/harbour-berlin-vegan.ts \
                translations/harbour-berlin-vegan-de.ts \
                translations/harbour-berlin-vegan-en.ts \
                translations/harbour-berlin-vegan-nl.ts



