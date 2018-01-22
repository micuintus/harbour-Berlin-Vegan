#pragma once

#include <QObject>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    bool exists(const QString& filename);
    QString read(const QString& filename);
    bool write(const QString& filename, const QString& data);

public:
    FileIO() {}

private:
    QString getWritableLocation();
};
