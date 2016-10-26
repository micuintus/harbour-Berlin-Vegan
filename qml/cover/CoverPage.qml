/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import "../components/distance.js" as Distance

import Sailfish.Silica 1.0
import QtPositioning 5.2
import QtQuick 2.2


CoverBackground {

    property var jsonModelCollection
    property var positionSource
    readonly property double listStretch: 1.15


    CoverActionList {
        id: actionlist

        iconBackground: true

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                positionSource.update();
                jsonModelCollection.invalidate();
            }
        }
    }

    SilicaListView {
        id: listView
        model: jsonModelCollection

        height: parent.height * 0.6

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.paddingLarge
        }

        header: Label {
            text: qsTr("Berlin vegan")
            color: Theme.highlightColor
            height: contentHeight * listStretch
        }

        delegate: ListItem {
            id: delegate

            contentHeight: namelabel.height * listStretch
            contentWidth: parent.width

            Label {
                id: namelabel
                text: model.name

                anchors {
                    right: distance.left
                    left: parent.left
                    rightMargin: Theme.paddingSmall
                    verticalCenter: parent.verticalCenter

                }

                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade

            }

            Label {
                id: distance
                text: positionSource.supportedPositioningMethods !== PositionSource.NoPositioningMethods ?
                Distance.humanReadableDistanceString(positionSource.position.coordinate,
                                                     QtPositioning.coordinate(model.latCoord, model.longCoord)) : ""
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }

        }



    }

}
