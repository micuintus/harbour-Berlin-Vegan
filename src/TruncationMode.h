#pragma once

#include <QObject>

class TruncationMode : public QObject
{
    Q_OBJECT

public:
    enum class Modes {
        Fade
    };
    Q_ENUMS(Modes)
};
