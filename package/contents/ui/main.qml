/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtWebEngine
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/backend.js" as Backend


PlasmoidItem {
    id: root
    width: 300
    height: 300

    property string haUrl: plasmoid.configuration.homeAssistantUrl
    property string bearerToken: plasmoid.configuration.bearerToken
    property string selectedEntities: plasmoid.configuration.selectedEntities


    ScrollView {
        anchors.fill: parent

        ColumnLayout {
            id: entityColumn
            width: parent.parent.width
            spacing: 0
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignCenter
                text: "Home Assistant"
            }
            Repeater {
                model: JSON.parse(selectedEntities)
                Loader {
                    Layout.fillWidth: true
                    //Layout.preferredHeight: 50
                    property var entity: modelData
                    source: {
                        switch (entity.domain) {
                            case "light": return "LightControl.qml"
							case "switch":
							case "input_boolean": return "SwitchControl.qml"
                            case "automation": return "AutomationControl.qml"
                            case "input_number": return "InputNumberControl.qml"
                            case "input_select": return "InputSelectControl.qml"
                            case "media_player": return "MediaPlayerControl.qml"
                            case "scene":
                            case "script": return "SceneButton.qml"
                            default: return "SensorDisplay.qml"
                        }
                    }
                    onLoaded: {
                        if (!item) return
                            item.Layout.fillWidth = true
                            item.entityId = entity.entity_id
                            item.isOn = entity.state === "on"
                        if (entity.raw && entity.raw.attributes) {
                            item.friendly_name = entity.raw.attributes.friendly_name
                            item.brightness = entity.raw.attributes.brightness || 0
                            item.value = entity.raw.state
                        }
                    }
                }
            }

            Kirigami.FormLayout {
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
        }
    }
}


    /*property int lastValue: 128
    property bool waitingToSend: false

    fullRepresentation: ColumnLayout {
        anchors.fill: parent
        spacing: 4
        PlasmaComponents3.Label {
            Layout.alignment: Qt.AlignCenter
            text: Plasmoid.nativeText
        }
        PlasmaComponents3.Slider {
            id: mySlider
            from: 0
            to: 100
            value: 50 // Default starting value
            stepSize: 5
            // You can also set the orientation for a vertical slider
            // orientation: Qt.Vertical
            onValueChanged: {
                lastValue = value
                if (!waitingToSend) {
                    waitingToSend = true
                    sendDelay.start()
                }

            }

        }

        // Timer that waits 0.5s after last change before sending request
        Timer {
            id: sendDelay
            interval: 500    // milliseconds
            repeat: false
            onTriggered: {
                sendBrightness(lastValue)
            }
        }
        function sendBrightness(val) {
            if (!haUrl || !bearerToken) {
                console.log("Home Assistant settings are missing")
                return
            }

            console.log("Sending brightness to Home Assistant:", val)
            const xhr = new XMLHttpRequest()
            xhr.open("POST", haUrl + "/api/services/light/turn_on")
            xhr.setRequestHeader("Authorization", "Bearer " + bearerToken)
            xhr.setRequestHeader("Content-Type", "application/json")

            const data = {
                entity_id: "light.schlafzimmer_3",
                brightness_pct: Math.round(val)
            }

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    console.log("Response:", xhr.status, xhr.responseText)
                }
            }

            xhr.send(JSON.stringify(data))
            waitingToSend = false
        }

        PlasmaComponents3.Label {
            Layout.alignment: Qt.AlignCenter
            function formatText(value){
                return i18n("%1%", value)
            }
            text: formatText(mySlider.value)
        }

        WebEngineView {
            id: web
            Layout.fillWidth: true
            Layout.fillHeight: true
            url: "http://10.1.1.38:8123"
        }
    }
}*/
