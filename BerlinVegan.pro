# The name of your application
TARGET = harbour-berlin-vegan

VERSION="0.8.6"

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

QT += positioning location

SOURCES += src/BerlinVegan.cpp \
           3rdparty/Cutehacks/gel/collection.cpp \
           3rdparty/Cutehacks/gel/jsonlistmodel.cpp

HEADERS += 3rdparty/Cutehacks/gel/gel.h \
           3rdparty/Cutehacks/gel/collection.h \
           3rdparty/Cutehacks/gel/jsonlistmodel.h \
           3rdparty/Cutehacks/gel/jsvalueiterator.h

RESOURCES += resources.qrc

packagesExist(sailfishapp) {
CONFIG += sailfishapp

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased

DEFINES += Q_OS_SAILFISH
} else {
CONFIG += v-play
RESOURCES += qml/Silica4v-play/resources-v-play.qrc
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}


# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-berlin-vegan-de.ts \
                translations/harbour-berlin-vegan-en.ts



