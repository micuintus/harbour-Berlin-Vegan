/**
 *
 *  This file is part of the Berlin-Vegan guide,
 *  Copyright 2015-2026 (c) by micu <micuintus.de> (post@micuintus.de).
 *
 *  The Berlin-Vegan guide is Free Software:
 *  you can redistribute it and/or modify it under the terms of the
 *  GNU General Public License as published by the Free Software Foundation,
 *  either version 2 of the License, or (at your option) any later version.
 *
 *  If not, see <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.
 *
**/

import QtQuick
import QtPositioning
import harbour.berlin.vegan 1.0
import BerlinVegan.components.platform 1.0 as BVApp
import BerlinVegan.components.ui 1.0 as BVApp

// Address search field with live Nominatim autocomplete.
// When the user picks a suggestion the coordinate property is updated
// and addressAccepted() is emitted.
Item {
    id: root

    property var coordinate: QtPositioning.coordinate()
    property string displayText: ""
    property string initialDisplayText: ""

    signal addressAccepted(var coordinate, string display)
    signal addressCleared()

    // Height grows to include the suggestion list when visible.
    implicitHeight: searchField.height + (dropdown.visible ? dropdown.height : 0)
    width: parent ? parent.width : 0

    BVApp.SearchField {
        id: searchField
        width: parent.width
        z: 0
        //% "Search address…"
        placeHolderText: qsTrId("id-address-search-placeholder")

        Component.onCompleted: {
            if (root.initialDisplayText.length > 0) {
                searchField.text = root.initialDisplayText
                searchField.textField.text = root.initialDisplayText
                root.displayText = root.initialDisplayText
            }
        }

        // SearchBar.text doesn't emit textChanged — wire to underlying AppTextField.
        Connections {
            target: searchField.textField
            enabled: root.visible
            function onTextChanged() {
                const t = searchField.textField.text
                if (t.length === 0) {
                    debounceTimer.stop()
                    suggestionModel.clear()
                    root.coordinate = QtPositioning.coordinate()
                    root.displayText = ""
                    root.addressCleared()
                } else if (t !== root.displayText) {
                    root.coordinate = QtPositioning.coordinate()
                    debounceTimer.restart()
                }
            }
        }

        Timer {
            id: debounceTimer
            interval: 100
            onTriggered: {
                const t = searchField.textField.text
                if (t.length >= 2)
                    NominatimService.searchAddresses(t, 8)
                else
                    suggestionModel.clear()
            }
        }
    }

    // Suggestion dropdown — positioned below the search field.
    Rectangle {
        id: dropdown
        z: 1
        y: searchField.height
        x: BVApp.Theme.horizontalPageMargin
        width: parent.width - 2 * BVApp.Theme.horizontalPageMargin
        height: suggestionList.contentHeight
        visible: suggestionModel.count > 0
        color: "white"
        radius: 4
        border.color: BVApp.Theme.dividerColor
        border.width: 1

        ListView {
            id: suggestionList
            width: parent.width
            height: contentHeight
            interactive: false
            clip: true
            model: ListModel { id: suggestionModel }

            delegate: Rectangle {
                id: suggestionDelegate
                width: ListView.view.width
                height: delegateColumn.height + 2 * BVApp.Theme.paddingMedium
                color: delegateMouseArea.pressed ? BVApp.Theme.secondaryHighlightColor : "white"
                radius: model.index === 0 || model.index === suggestionModel.count - 1 ? dropdown.radius : 0

                Behavior on color { ColorAnimation { duration: 120 } }

                Column {
                    id: delegateColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: BVApp.Theme.paddingMedium
                        rightMargin: BVApp.Theme.paddingMedium
                    }
                    spacing: 2

                    BVApp.Label {
                        width: parent.width
                        text: model.line1
                        font.pixelSize: BVApp.Theme.fontSizeSmall
                        color: BVApp.Theme.primaryColor
                        elide: Text.ElideRight
                    }

                    BVApp.Label {
                        width: parent.width
                        text: model.line2
                        font.pixelSize: BVApp.Theme.fontSizeExtraSmall
                        color: BVApp.Theme.secondaryColor
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }
                }

                // Divider between rows
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: BVApp.Theme.paddingMedium
                    anchors.rightMargin: BVApp.Theme.paddingMedium
                    height: 1
                    color: BVApp.Theme.dividerColor
                    opacity: 0.5
                    visible: model.index < suggestionModel.count - 1
                }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent
                    onClicked: {
                        const lat = parseFloat(model.lat)
                        const lon = parseFloat(model.lon)
                        const coord = QtPositioning.coordinate(lat, lon)
                        const display = model.line2.length > 0
                            ? model.line1 + ", " + model.line2
                            : model.line1

                        root.coordinate = coord
                        root.displayText = display
                        searchField.text = display
                        searchField.textField.text = display
                        suggestionModel.clear()
                        Qt.inputMethod.hide()

                        root.addressAccepted(coord, display)
                    }
                }
            }
        }
    }

    // Only active when this instance is the visible one — prevents the hidden
    // instance (pre-created by filterSettingsComponent) from consuming results.
    Connections {
        target: NominatimService
        enabled: root.visible
        function onSearchResults(results) {
            suggestionModel.clear()
            for (let i = 0; i < results.length; ++i) {
                const r = results[i]
                const addr = r["address"] || {}

                let line1 = addr["road"] || r["name"] || ""
                const houseNum = addr["house_number"] || ""
                if (houseNum.length > 0 && line1.length > 0)
                    line1 += " " + houseNum

                const postcode = addr["postcode"] || ""
                const city = addr["city"] || addr["town"] || addr["village"] || addr["municipality"] || ""
                const suburb = addr["suburb"] || addr["quarter"] || ""
                let line2 = postcode.length > 0 ? postcode + " " + city : city
                if (suburb.length > 0 && suburb !== city)
                    line2 += (line2.length > 0 ? ", " : "") + suburb

                suggestionModel.append({
                    "line1":       line1.length > 0 ? line1 : (r["display_name"] || ""),
                    "line2":       line2,
                    "lat":         r["lat"] || "0",
                    "lon":         r["lon"] || "0",
                    "displayName": r["display_name"] || ""
                })
            }
        }
    }
}
