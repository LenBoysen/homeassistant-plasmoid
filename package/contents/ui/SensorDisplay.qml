import QtQuick 2.15
import QtWebSockets
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import "../code/backend.js" as Backend

Item {
    id: root
    Layout.fillWidth: true
    height: 40 // Sensors are typically compact text displays

    // Configuration properties populated by main.qml Loader
    property string haUrl: plasmoid.configuration.homeAssistantUrl
    property string bearerToken: plasmoid.configuration.bearerToken

    property string entityId: ""
    property string friendly_name: ""
    property string value: "" // Populated initially from main.qml raw state

    // Internal tracker for unit of measurement
    property string unitOfMeasurement: ""

    onEntityIdChanged: {
        if (!entityId || entityId === "") return

        // Initial fetch of state via REST API on startup
        Backend.getState(entityId, function(resp) {
            if (resp) {
                root.value = resp.state
                if (resp.attributes && resp.attributes.unit_of_measurement) {
                    root.unitOfMeasurement = resp.attributes.unit_of_measurement
                }
                if (!root.friendly_name && resp.attributes && resp.attributes.friendly_name) {
                    root.friendly_name = resp.attributes.friendly_name
                }
            }
        })
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        Kirigami.FormLayout {
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 10

            // Display the sensor's name
            PlasmaComponents3.Label {
                id: nameLabel
                text: root.friendly_name || root.entityId
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Display the sensor's value + unit
            PlasmaComponents3.Label {
                id: valueLabel
                text: root.unitOfMeasurement ? (root.value + " " + root.unitOfMeasurement) : root.value
                horizontalAlignment: Text.AlignRight
                Layout.maximumWidth: parent.width * 0.4
                elide: Text.ElideRight
            }
        }
    }
    // WebSocket implementation to listen for real-time sensor updates
    WebSocket {
        id: haSocket
        url: haUrl.replace(/^http/, "ws") + "/api/websocket"
        active: true
        
        onStatusChanged: function(status) {
            if (status === WebSocket.Open) {
                // Authenticate
                sendTextMessage(JSON.stringify({
                    type: "auth",
                    access_token: bearerToken
                }))
                // Subscribe to state changes
                sendTextMessage(JSON.stringify({
                    id: 2, // Unique ID per subscription item
                    type: "subscribe_events",
                    event_type: "state_changed"
                }))
            }
        }

        onTextMessageReceived: (message) => {
            const data = JSON.parse(message)
            if (data.type === "event" && data.event?.data?.new_state) {
                const newState = data.event.data.new_state
                
                // Match this incoming update to our exact entityId
                if (newState.entity_id === root.entityId) {
                    root.value = newState.state
                    if (newState.attributes && newState.attributes.unit_of_measurement) {
                        root.unitOfMeasurement = newState.attributes.unit_of_measurement
                    }
                }
            }
        }
    }
}