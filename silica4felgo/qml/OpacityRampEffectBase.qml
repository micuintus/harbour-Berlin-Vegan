/*
Copyright (C) 2015 Jolla Ltd.
Contact: Gunnar Sletta <gunnar.sletta@jollamobile.com>
All rights reserved.

This file is part of Sailfish Silica UI component package.

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

import QtQuick

ShaderEffect {
    id: root

    // API -----------------------

    // Opacity reduces linearly over the span of the item, affected by two
    // tunable properties:
    //  - the slope of the reduction (default 2.0, meaning 100% across half the width)
    //  - the offset from which the reduction is applied (default 0.5, meaning half the width)
    property real slope: 2.0
    property real offset: 0.5

    // clamp will be applied: clamp(factor + ramp value, min, max)
    property real clampFactor: 0.0
    property real clampMin: 0.0
    property real clampMax: 1.0

    // LtR = 0, RtL = 1, TtB = 2, BtT = 3
    property int direction: 0 // default = LeftToRight-OpaqueToTranslucent

    // impl. ---------------------
    property var source

    vertexShader: "qrc:/OpacityRampShaders/shaders/opacity_ramp.vert.qsb"
    fragmentShader: "qrc:/OpacityRampShaders/shaders/opacity_ramp.frag.qsb"
}
