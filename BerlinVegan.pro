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

packagesExist(sailfishapp) {
CONFIG += sailfishapp

DEFINES += Q_OS_SAILFISH
} else {
CONFIG += v-play

qmlFolder.source = qml
DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

linux {
    wrapperFolder.source = qml/Silica4v-play/Sailfish
    DEPLOYMENTFOLDERS += wrapperFolder
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}

# Add more folders to ship with the application here

RESOURCES += #    resources.qrc # uncomment for publishing

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the DEPLOYMENTFOLDERS += qmlFolder line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the resources.qrc file inclusion and add any qml subfolders to the .qrc file; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the V-Play Documentation

# during development, use the qmlFolder deployment because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted
}

QT += positioning location

SOURCES += src/BerlinVegan.cpp \
           3rdparty/Cutehacks/gel/collection.cpp \
           3rdparty/Cutehacks/gel/jsonlistmodel.cpp

HEADERS += 3rdparty/Cutehacks/gel/gel.h \
           3rdparty/Cutehacks/gel/collection.h \
           3rdparty/Cutehacks/gel/jsonlistmodel.h \
           3rdparty/Cutehacks/gel/jsvalueiterator.h

packagesExist(sailfishapp) {
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
    qml/components/JsonDownloadHelper.qml \
    qml/components/OpeningHoursModelAlgorithms.js \
    qml/components/VenueDescriptionAlgorithms.js \
    qml/components/distance.js \
    translations/harbour-berlin-vegan-de.ts \
    translations/harbour-berlin-vegan-en.ts

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased
}

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-berlin-vegan-de.ts \
                translations/harbour-berlin-vegan-en.ts

VERSION="0.8.6"

DEFINES += APP_VERSION=\\\"$$VERSION\\\"
