#pragma once

#include <QtQuick>

class MouseStealingProtector : public QQuickItem {
    Q_OBJECT

public:
    MouseStealingProtector(QQuickItem *parent=0)
        : QQuickItem(parent)
    {
        setKeepMouseGrab(true);
        setKeepTouchGrab(true);
        setAcceptedMouseButtons(Qt::LeftButton);
        grabMouse();
        setFiltersChildMouseEvents(true);
    }

    virtual ~MouseStealingProtector() {}
};
