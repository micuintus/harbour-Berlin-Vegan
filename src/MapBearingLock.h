#pragma once

#include <QObject>
#include <QQmlEngine>

// Locks a Map's bearing and tilt to 0 via synchronous C++ signal connection.
// QML-based approaches (Binding, Connections, SmoothedAnimation) all fail
// because they execute asynchronously — after the gesture code has already
// rendered a rotated frame.  A direct C++ connection fires synchronously
// inside the signal emission, resetting bearing before the render pipeline
// sees the changed value.
class MapBearingLock : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QObject* target READ target WRITE setTarget NOTIFY targetChanged)

public:
    explicit MapBearingLock(QObject *parent = nullptr) : QObject(parent) {}

    QObject *target() const { return m_target; }

    void setTarget(QObject *t)
    {
        if (m_target == t)
            return;

        if (m_target) {
            disconnect(m_target, SIGNAL(bearingChanged()), this, SLOT(resetBearing()));
            disconnect(m_target, SIGNAL(tiltChanged()), this, SLOT(resetTilt()));
        }

        m_target = t;

        if (m_target) {
            connect(m_target, SIGNAL(bearingChanged()), this, SLOT(resetBearing()),
                    Qt::DirectConnection);
            connect(m_target, SIGNAL(tiltChanged()), this, SLOT(resetTilt()),
                    Qt::DirectConnection);
        }

        emit targetChanged();
    }

signals:
    void targetChanged();

private slots:
    void resetBearing()
    {
        if (m_resetting || !m_target)
            return;
        m_resetting = true;
        m_target->setProperty("bearing", 0.0);
        m_resetting = false;
    }

    void resetTilt()
    {
        if (m_resetting || !m_target)
            return;
        m_resetting = true;
        m_target->setProperty("tilt", 0.0);
        m_resetting = false;
    }

private:
    QObject *m_target = nullptr;
    bool m_resetting = false;
};
