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
TARGET = harbour-berlin-vegan

CONFIG += sailfishapp
QT += positioning location

SOURCES += src/BerlinVegan.cpp \
           3rdparty/Cutehacks/gel/collection.cpp \
           3rdparty/Cutehacks/gel/jsonlistmodel.cpp

HEADERS += 3rdparty/Cutehacks/gel/gel.h \
           3rdparty/Cutehacks/gel/collection.h \
           3rdparty/Cutehacks/gel/jsonlistmodel.h \
           3rdparty/Cutehacks/gel/jsvalueiterator.h

OTHER_FILES += harbour-berlin-vegan.desktop \
    rpm/BerlinVegan.yaml \
    rpm/harbour-berlin-vegan.changes \
    rpm/harbour-berlin-vegan.spec \
    qml/harbour-berlin-vegan.qml \
    qml/cover/CoverPage.qml \
    qml/pages/VenueList.qml \
    qml/pages/VenueDescription.qml \
    qml/pages/VenueMapPage.qml \
    qml/pages/GastroLocations.json \
    qml/pages/about/AboutBerlinVegan.qml \
    qml/pages/about/LicenseViewer.qml \
    qml/pages/about/ThirdPartySoftware.qml \
    qml/pages/about/LICENSE \
    qml/pages/about/LICENSE.Cutehacks \
    qml/pages/about/LICENSE.YTPlayer \
    qml/pages/about/LICENSE.qml-utils \
    qml/pages/about/CC-by-nc-legalcode.txt \
    qml/pages/about/BerlinVegan.svg \
    qml/components/VenueDescriptionHeader.qml \
    qml/components/IconToolBar.qml \
    qml/components/CollapsibleItem.qml \
    qml/components/OpeningHoursModel.qml \
    qml/components/VenueDetails.qml \
    qml/components/OpeningHoursModelAlgorithms.js \
    qml/components/VenueDescriptionAlgorithms.js \
    qml/components/distance.js \
    qml/components/JSONDownloadHelper.js \
    translations/harbour-berlin-vegan-de.ts \
    translations/harbour-berlin-vegan-en.ts

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-berlin-vegan-de.ts \
                translations/harbour-berlin-vegan-en.ts

VERSION="0.8.6"

DEFINES += APP_VERSION=\\\"$$VERSION\\\"




