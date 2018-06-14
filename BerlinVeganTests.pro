TARGET = BerlinVeganTests

QT += testlib quick

CONFIG += qt c++11

SOURCES += tests/BerlinVeganTests.cpp \
           tests/OpeningHoursAlgorithmsTests.cpp

HEADERS += src/OpeningHoursAlgorithms.h \
           tests/OpeningHoursAlgorithmsTests.h
