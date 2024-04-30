#pragma once

#include "qqmlintegration.h"
#include <QObject>

class TruncationMode : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum class Modes {
        Fade
    };
    Q_ENUMS(Modes)
};
