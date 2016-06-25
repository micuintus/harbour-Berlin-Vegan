/*
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
 //   width: 400
 //   height: 600


        SilicaListView {
            id: list1
            anchors.fill: parent
            height: 200

            JSONListModel {
                id: jsonModel1
                source: "../pages/GastroLocations.json"

                query: "$.[*]"
            }
            model: jsonModel1.model

            delegate: BackgroundItem {
                Text {
                    Label {
                        x: Theme.paddingLarge
                        text: model.name
                        anchors.verticalCenter: parent.verticalCenter
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                }
            }

    }
}
