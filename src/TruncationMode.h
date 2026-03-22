#pragma once

#include <QObject>

// TruncationMode enum for text truncation in QML.
// Values match Sailfish Silica's TruncationMode for compatibility.
// Registered manually via qmlRegisterUncreatableType in BerlinVegan.cpp.
class TruncationMode : public QObject
{
    Q_OBJECT

public:
    enum Modes {
        None = 0,
        Elide = 1,
        Fade = 2
    };
    Q_ENUM(Modes)
};
