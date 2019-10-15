#pragma once

#include "VenueModel.h"
#include <QObject>
#include <functional>

class VenueHandle : public QObject
{
    Q_OBJECT

#define ROLE_NAME_ID_PAIR(NAME, ID)                             \
    Q_PROPERTY(QVariant NAME READ NAME NOTIFY NAME##Changed)
    ROLE_NAME_ID_PAIRS
#undef ROLE_NAME_ID_PAIR

public:
    VenueHandle(QPersistentModelIndex&& persIndex)
    : m_index(std::move(persIndex))
    {
        const auto* model = m_index.model();
        const auto& index = static_cast<QModelIndex>(m_index);
        connect(model, &QAbstractItemModel::dataChanged, this,
        [&](const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles)
        {
            static QHash<VenueModel::VenueModelRoles, std::function<void(VenueHandle*)>> s_roleToChangedSignal =
            {
            #define ROLE_NAME_ID_PAIR(NAME, ID)                             \
                { VenueModel::VenueModelRoles::ID, &VenueHandle::NAME##Changed },
                ROLE_NAME_ID_PAIRS
            };
            #undef ROLE_NAME_ID_PAIR

            if (index < topLeft || bottomRight < bottomRight)
                return;

            for (const int role : roles)
            {
                const auto& signal = s_roleToChangedSignal[static_cast<VenueModel::VenueModelRoles>(role)];
                signal(this);
            }
        });
    }

#define ROLE_NAME_ID_PAIR(NAME, ident)                         \
    QVariant NAME() const                                      \
    {                                                          \
      return m_index.data(VenueModel::VenueModelRoles::ident); \
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
