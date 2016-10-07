# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = BerlinVegan

QT +=  positioning

CONFIG += sailfishapp

SOURCES += src/BerlinVegan.cpp \
           3rdparty/Cutehacks/gel/collection.cpp \
           3rdparty/Cutehacks/gel/jsonlistmodel.cpp

HEADERS += 3rdparty/Cutehacks/gel/gel.h \
3rdparty/Cutehacks/gel/collection.h \
3rdparty/Cutehacks/gel/jsonlistmodel.h \
3rdparty/Cutehacks/gel/jsvalueiterator.h


OTHER_FILES += qml/BerlinVegan.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/BerlinVegan.changes.in \
    rpm/BerlinVegan.spec \
    rpm/BerlinVegan.yaml \
    translations/BerlinVegan-de.ts \
    BerlinVegan.desktop \
    qml/pages/GastroLocations.json \
    qml/pages/GastroLocationList.qml \
    qml/pages/GastroLocationDescription.qml \
    qml/components/IconToolBar.qml \
    qml/components/CollapsibleItem.qml \
    qml/components/OpeningHoursModel.qml \
    qml/components/OpeningHoursModelAlgorithms.js \
    qml/components/GastroLocationDescriptionAlgorithms.js \
    qml/components/distance.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/BerlinVegan-de.ts
