# The name of your application
TARGET = harbour-berlin-vegan

VERSION="3.6.3alpha"

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

QT += positioning location

CONFIG += c++11

SOURCES += src/BerlinVegan.cpp \
           src/FileIO.cpp \
           src/VenueModel.cpp \
           src/VenueSortFilterProxyModel.cpp

HEADERS += src/VenueModel.h \
           src/VenueHandle.h \
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

RESOURCES += qml/components-sailfish/resources-components-sailfish.qrc

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased

} else {
CONFIG    += felgo
RESOURCES += qml/silica4felgo/resources-silica4felgo.qrc \
             qml/components-felgo/resources-components-felgo.qrc
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

    # Set ID - fix for Qt = 5.11.1 - https://bugreports.qt.io/browse/QTBUG-70072
    equals(QT_MAJOR_VERSION, 5):equals(QT_MINOR_VERSION, 11):equals(QT_PATCH_VERSION, 1) {
      load(default_post.prf)
    }
    xcode_product_bundle_identifier_setting.value = "org.berlin-vegan.bvapp"

    # Set ID - Qt >= 5.12
    QMAKE_TARGET_BUNDLE_PREFIX = "org.berlin-vegan"
    QMAKE_BUNDLE = "bvapp"
}

TRANSLATIONS += translations/harbour-berlin-vegan.ts \
                translations/harbour-berlin-vegan-de.ts \
                translations/harbour-berlin-vegan-en.ts \
                translations/harbour-berlin-vegan-nl.ts



