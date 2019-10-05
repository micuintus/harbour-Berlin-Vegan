#pragma once

#include "VenueModel.h"
#include <QObject>

class VenueHandle : public QObject
{
    Q_OBJECT

#define ROLE_NAME_ID_PAIR(NAME, ID) \
    Q_PROPERTY(QVariant NAME READ NAME NOTIFY NAME##Changed)
    ROLE_NAME_ID_PAIRS
#undef ROLE_NAME_ID_PAIR

public:
    VenueHandle(QPersistentModelIndex&& index) : m_index(std::move(index))
    {
    }


#define ROLE_NAME_ID_PAIR(NAME, ident) \
    QVariant NAME() const             \
    {                               \
      return m_index.data(VenueModel::VenueModelRoles::ident);      \
    }
    ROLE_NAME_ID_PAIRS
#undef ROLE_NAME_ID_PAIR

signals:
#define ROLE_NAME_ID_PAIR(NAME, ID) \
    void NAME##Changed();
    ROLE_NAME_ID_PAIRS
#undef ROLE_NAME_ID_PAIR

private:
    const QPersistentModelIndex m_index;
};

Q_DECLARE_INTERFACE(VenueHandle, "harbour.berlin.vegan.VenueHandle")
