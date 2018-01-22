#include "FileIO.h"

bool FileIO::exists(const QString& filename)
{
    if (filename.isEmpty())
        return false;

    QString source = getWritableLocation() + filename;
    QFile file(source);
    if (file.exists() && file.open(QFile::ReadOnly))
    {
        file.close();
        return true;
    }

    return false;
}

QString FileIO::read(const QString& filename)
{
    if (filename.isEmpty())
        return "";

    QString source = getWritableLocation() + filename;
    QFile file(source);
    if (!file.open(QFile::ReadOnly))
        return "";

    QTextStream in(&file);
    QString data;
    data = in.readAll();
    file.close();
    return data;
}

bool FileIO::write(const QString& filename, const QString& data)
{
    if (filename.isEmpty())
        return false;

    QString source = getWritableLocation() + filename;
    QFile file(source);
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
    out << data;
    file.close();
    return true;
}

QString FileIO::getWritableLocation()
{
    return QStandardPaths::writableLocation(QStandardPaths::DataLocation) + QDir::separator();
}
