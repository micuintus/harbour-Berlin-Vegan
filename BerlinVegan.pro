# The name of your application
TARGET = harbour-berlin-vegan

VERSION="0.8.6"

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

QT += positioning location

CONFIG += c++11

SOURCES += src/BerlinVegan.cpp \
           3rdparty/Cutehacks/gel/collection.cpp \
           3rdparty/Cutehacks/gel/jsonlistmodel.cpp

HEADERS += 3rdparty/Cutehacks/gel/gel.h \
           3rdparty/Cutehacks/gel/collection.h \
           3rdparty/Cutehacks/gel/jsonlistmodel.h \
           3rdparty/Cutehacks/gel/jsvalueiterator.h

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
}

TRANSLATIONS += translations/harbour-berlin-vegan-de.ts \
                translations/harbour-berlin-vegan-en.ts



