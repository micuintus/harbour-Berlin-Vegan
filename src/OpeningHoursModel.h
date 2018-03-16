#pragma once

#include "VenueModel.h"

#include <QObject>
#include <QStringListModel>

#include <QtQml/QJSValue>

class OpeningHoursModel : public QStringListModel
{
    Q_OBJECT

    Q_PROPERTY(QJSValue restaurant READ restaurant WRITE setRestaurant)
    Q_PROPERTY(int count READ count)

public:
    Q_INVOKABLE QMap<QString, QVariant> get(const int index) const;
    Q_INVOKABLE void set(const int index, const QMap<QString, QVariant> map);
    Q_INVOKABLE bool remove(const int index);
    Q_INVOKABLE void condenseOpeningHoursModel();

    OpeningHoursModel(QObject *parent = 0);

    QHash<int, QByteArray> roleNames() const;
    QVariant data(const QModelIndex &index, int role) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

signals:
    void restaurantChanged();

private:
    QJSValue restaurant() const { return m_restaurant; }
    int count() const { return m_data.size(); }

    void setRestaurant(const QJSValue& restaurant);

    void mergeElements(const int from, const int to);
    void cleanUpOpeningHoursModel();

    QJSValue m_restaurant;

    // we save 7 days with 2 each attributes (name and opening hours), e.g.
    //
    // QMap(("day", QVariant(QString, "Monday"))("hours", QVariant(QString, "12 - 22")))
    //
    // Syntax from: http://www.cplusplus.com/forum/beginner/12409/
    QVector<QVector<QString>> m_data = QVector<QVector<QString>>(7, QVector<QString>(2, 0));
};
