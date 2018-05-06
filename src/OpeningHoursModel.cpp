/**
 *
 *  This file is part of the Berlin-Vegan guide (SailfishOS app version),
 *  Copyright 2015-2018 (c) by micu <micuintus.de> (post@micuintus.de).
 *  Copyright 2017-2018 (c) by jmastr <veggi.es> (julian@veggi.es).
 *
 *      <https://github.com/micuintus/harbour-Berlin-vegan>.
 *
 *  The Berlin-Vegan guide is Free Software:
 *  you can redistribute it and/or modify it under the terms of the
 *  GNU General Public License as published by the Free Software Foundation,
 *  either version 2 of the License, or (at your option) any later version.
 *
 *  Berlin-Vegan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with The Berlin Vegan Guide.
 *
 *  If not, see <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.
 *
**/

#include "OpeningHoursModel.h"

QMap<QString, QVariant> OpeningHoursModel::get(const int index) const
{
    // get it in JSON-style for QML
    QMap<QString, QVariant> map;
    map.insert("day", QVariant(m_data[index][0]));
    map.insert("hours", QVariant(m_data[index][1]));
    return map;
}

void OpeningHoursModel::set(const int index, const QMap<QString, QVariant> map)
{
    // we are able to set JSON-style either one or theother or both keys
    const auto vday = map.value("day").toString();
    if (!vday.isEmpty())
    {
        m_data[index][0] = vday;
    }

    const auto vhours = map.value("hours").toString();
    if (!vhours.isEmpty())
    {
        m_data[index][1] = vhours;
    }

    QModelIndex i = this->index(index, 0);
    emit dataChanged(i, i);
}

bool OpeningHoursModel::remove(const int index)
{
    if (index < 0 || index > m_data.size() - 1)
        return false;

    // without {begin|end}RemoveRows() the UI is not updated
    // https://code.woboq.org/qt5/qtbase/src/corelib/itemmodels/qstringlistmodel.cpp.html#244
    beginRemoveRows(QModelIndex(), index, index);
    m_data.remove(index);
    endRemoveRows();

    return true;
}

void OpeningHoursModel::condenseOpeningHoursModel()
{
    const auto initSize = count();
    int lastEqualItemIndex = -1;

    if (initSize <= 1)
    {
        return;
    }

    // iterating from the first to the second last item, models are 0 indexed
    for (int i = 0; i <= initSize - 2 ; i++)
    {
        const auto currElem = this->get(i + 0);
        const auto nextElem = this->get(i + 1);

        if (currElem.value("hours") == nextElem.value("hours"))
        {
            if (lastEqualItemIndex == -1)
            {
                lastEqualItemIndex = i;
            }

            if (i == initSize - 2)
            {
                mergeElements(lastEqualItemIndex, i + 1);
            }
        }
        else
        {
            if (lastEqualItemIndex != -1)
            {
                mergeElements(lastEqualItemIndex, i);
                lastEqualItemIndex = -1;
            }
        }
    }

    cleanUpOpeningHoursModel();
}

OpeningHoursModel::OpeningHoursModel(QObject *parent) :
    QStringListModel(parent),
    m_isOpen(false)
{
}

QHash<int, QByteArray> OpeningHoursModel::roleNames() const
{
    // define both roles, so we can access them in QML via 'model.foobar'
    QHash<int, QByteArray> roles;
    roles.insert(Qt::UserRole + 1, "day");
    roles.insert(Qt::UserRole + 2, "hours");
    return roles;
}

QVariant OpeningHoursModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (!index.isValid()) {
        return value;
    }

    if (role < Qt::UserRole)
    {
        value = QStringListModel::data(index, role);
    }

    int columnIdx;
    switch (role)
    {
    case Qt::UserRole + 1:
        columnIdx = role - Qt::UserRole - 1;
        value = QVariant(m_data[index.row()][columnIdx]);
        break;
    case Qt::UserRole + 2:
        columnIdx = role - Qt::UserRole - 1;
        value = QVariant(m_data[index.row()][columnIdx]);
        break;
    default:
        break;
    }
    return value;
}

int OpeningHoursModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_data.size();
}

void OpeningHoursModel::isOpen()
{
    const auto dateTime = QDateTime::currentDateTime();
    // isOpen
    const auto currentHour = dateTime.time().hour();
    auto currentMinute = currentHour * 60 + dateTime.time().minute();
    // getOpeningHours
    const auto sundayIndex = 6;
    auto dayOfWeek = dateTime.date().dayOfWeek() - 1; // Friday is 5, but we count from 0, so we need 4

    if (isAfterMidnight(dateTime))
    {
        currentMinute += 24 * 60; // add a complete day
        dayOfWeek = dayOfWeek - 1; // its short after midnight, so we use the opening hour from the day before
        if (dayOfWeek == -1)
        {
            dayOfWeek = sundayIndex; // sunday
        }
    }

    if (isPublicHoliday(dateTime)) // it is a holiday so take the opening hours from sunday
    {
        dayOfWeek = sundayIndex;
    }

    m_isOpen = isInRange(get(dayOfWeek).value("hours").toString(), currentMinute);
    emit isOpenChanged();
}

void OpeningHoursModel::setOpeningData(const QJSValue& openingData)
{
    m_openingData = openingData;

    QMap<QString, QVariant> map = m_openingData.toVariant().toMap();
                         //% "Monday"
    m_data[0][0] = qtTrId("id-monday");
    m_data[0][1] = map.value("otMon").toString();
                         //% "Tuesday"
    m_data[1][0] = qtTrId("id-tuesday");
    m_data[1][1] = map.value("otTue").toString();
                         //% "Wednesday"
    m_data[2][0] = qtTrId("id-wednesday");
    m_data[2][1] = map.value("otWed").toString();
                         //% "Thursday"
    m_data[3][0] = qtTrId("id-thursday");
    m_data[3][1] = map.value("otThu").toString();
                         //% "Friday"
    m_data[4][0] = qtTrId("id-friday");
    m_data[4][1] = map.value("otFri").toString();
                         //% "Saturday"
    m_data[5][0] = qtTrId("id-saturday");
    m_data[5][1] = map.value("otSat").toString();
                         //% "Sunday"
    m_data[6][0] = qtTrId("id-sunday");
    m_data[6][1] = map.value("otSun").toString();

    isOpen();
}

void OpeningHoursModel::mergeElements(const int from, const int to)
{
    const auto fromElementDay = this->get(from).value("day").toString();
    const auto toElementDay   = this->get(to).value("day").toString();
    const auto hours          = this->get(from).value("hours").toString();

    QMap<QString, QVariant> map;
    map.insert("day", QVariant(fromElementDay + " - " + toElementDay));
    map.insert("hours", QVariant(hours));
    set(from, map);
    map.clear();

    for (int i = from + 1; i <= to; i++)
    {
        map.insert("day", QVariant("flagDeleteDummy"));
        map.insert("hours", QVariant("flagDeleteDummy"));
        set(i, map);
        map.clear();
    }
}

void OpeningHoursModel::cleanUpOpeningHoursModel()
{
    auto c = count();
    for (int i = 0; i < c; i++)
    {
        while (i < c && get(i).value("hours").toString() == "flagDeleteDummy")
        {
            remove(i);
            c--;
        }
    }

    // Fix: TypeError: Cannot read property 'hours' of undefined
    QMap<QString, QVariant> map;
    for (int i = 0; i < c; i++)
    {
        if (get(i).value("hours").toString().isEmpty())
        {
                                               //% "closed"
            map.insert("hours", QVariant(qtTrId("id-closed")));
            set(i, map);
            map.clear();
        }
    }
}

// Start: Port from Android app
bool OpeningHoursModel::isAfterMidnight(const QDateTime &dateTime) const
{
    const auto currentHour = dateTime.time().hour();
    return currentHour >= 0 && currentHour <= 6;
}

bool OpeningHoursModel::isPublicHoliday(const QDateTime &dateTime) const
{
    // calulate easter date
    // https://stackoverflow.com/a/1284335
    const auto Y = dateTime.date().year();
    const auto C = qFloor(Y/100);
    const auto N = Y - 19*qFloor(Y/19);
    const auto K = qFloor((C - 17)/25);
    auto I = C - qFloor(C/4) - qFloor((C - K)/3) + 19*N + 15;
    I = I - 30*qFloor((I/30));
    I = I - qFloor(I/28)*(1 - qFloor(I/28)*qFloor(29/(I + 1))*qFloor((21 - N)/11));
    auto J = Y + qFloor(Y/4) + I + 2 - C + qFloor(C/4);
    J = J - 7*qFloor(J/7);
    const auto L = I - J;
    const auto M = 3 + qFloor((L + 40)/44);
    const auto D = L + 28 - 31*qFloor(M/4);
    // easter sunday
    const QDate es(Y, M, D);

    // form https://publicholidays.de/berlin/2018-dates/
    // new year's eve
    const QDate ny(Y, 1, 1);
    // good friday
    const QDate gf(es.addDays(-2));
    // easter monday
    const QDate em(es.addDays(1));
    // labour day
    const QDate ld(es.addDays(30));
    // ascension day
    const QDate as(es.addDays(39));
    // whit monday
    const QDate wm(es.addDays(50));
    // day of german unity
    const QDate gu(Y, 10, 3);
    // christmas day
    const QDate cd(Y, 12, 25);
    // 2nd day of christmas
    const QDate dc(Y, 12, 26);

    // C++ doesn't allow for non-integral types in switch statements
    const auto date = dateTime.date();
    if (date == ny)
        return true;
    else if (date == gf)
        return true;
    else if (date == em)
        return true;
    else if (date == ld)
        return true;
    else if (date == as)
        return true;
    else if (date == wm)
        return true;
    else if (date == gu)
        return true;
    else if (date == cd)
        return true;
    else if (date == dc)
        return true;
    return false;
}

bool OpeningHoursModel::isInRange(const QString openingHours, const int currentMinute) const
{
    auto startMinute = 0;
    auto endMinute = 0;
    if (openingHours.contains("-"))
    {
        const auto parts = openingHours.split("-");
        const auto startTime = parts[0];
        startMinute = getMinute(startTime);
        if (parts.size() > 1)
        {
            const auto endTime = parts[1];
            endMinute = getMinute(endTime);
            if (startMinute != 0 && endMinute == 0)
            {
                endMinute = 24 * 60;
            }
        }
        else if (startMinute != 0)
        {
            endMinute = 24 * 60;
        }
    }

    auto endMinutes = endMinute;
    if (endMinute < startMinute) // closing time is after midnight
    {
        endMinutes = endMinutes + 24 * 60;
    }

    return currentMinute >= startMinute && currentMinute <= endMinutes;
}

int OpeningHoursModel::getMinute(const QString time) const
{
    if (time == NULL || time.isEmpty())
    {
        return 0;
    }

    auto hour = 0;
    auto minute = 0;
    if (time.contains(":"))
    {
        const auto parts = time.split(":");
        hour = parts[0].trimmed().toInt();
        minute = parts[1].trimmed().toInt();
    }
    else
    {
        hour = time.trimmed().toInt();
    }

    return hour * 60 + minute;
}
// End: Port from Android app
