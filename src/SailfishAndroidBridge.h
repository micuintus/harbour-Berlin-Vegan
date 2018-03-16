#pragma once

#include <QObject>
#include <QString>

class SailfishAndroidBridge : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE void startURIIntent(const QString& intent, const QString& intentDataURI);

    void initBridge();
};
