#pragma once

#include "qqmlintegration.h"
#include <QObject>

// TruncationMode enum for text truncation in QML.
// Values match Sailfish Silica's TruncationMode for compatibility.
class TruncationMode : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Modes {
        None = 0,
        Elide = 1,
        Fade = 2
    };
    Q_ENUM(Modes)
};
