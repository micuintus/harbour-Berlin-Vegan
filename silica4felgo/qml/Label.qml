/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick
import QtQuick.Window

import Sailfish.Silica 1.0
import BerlinVegan.components.platform 1.0 as BVApp

Text {
    id: root

    property int truncationMode

    // lineCount == 1 would cause the _fadeText binding to be unoptimized.
    // Workaround with x >= 1 && x <= 1
    property bool _fadeText: (width > 0) && (truncationMode == TruncationMode.Fade) && (lineCount >= 1) && (lineCount <= 1) && (contentWidth > Math.ceil(width))
    property bool _elideText: (truncationMode == TruncationMode.Elide) || (truncationMode == TruncationMode.Fade && lineCount > 1)
    property alias _rampEffect: rampEffect

    elide: _elideText ? (horizontalAlignment == Text.AlignLeft ? Text.ElideRight
                                                               : (horizontalAlignment == Text.AlignRight ? Text.ElideLeft
                                                                                                         : Text.ElideMiddle))
                          : Text.ElideNone

    color: BVApp.Theme.primaryColor
    font.pixelSize: BVApp.Theme.fontSizeMedium

    Item {
        parent: root.parent
        x: root.x
        y: root.y
        OpacityRampEffect {
            id: rampEffect

            sourceItem: root
            enabled: _fadeText
            direction: horizontalAlignment == Text.AlignRight ? 1//OpacityRamp.RightToLeft
                                                              : 0//OpacityRamp.LeftToRight

            slope: 1 + 6 * root.width / Screen.width
            offset: 1 - 1 / slope
            width: root.width
            height: root.height
            anchors.fill: null
        }
    }
}
