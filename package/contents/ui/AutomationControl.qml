// AutomationControl.qml
import QtQuick 2.15
import QtWebSockets
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../code/backend.js" as Backend
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PC3


Item {
    id: root
    // make it expand properly in ColumnLayout
    Layout.fillWidth: true
    //Layout.preferredHeight: content.childrenRect.height + 10
    height: 80

    property string haUrl: plasmoid.configuration.homeAssistantUrl
    property string bearerToken: plasmoid.configuration.bearerToken

    property string value: ""
    property string options: ""
    property string entityId: ""
    property string friendly_name: ""
    property bool isOn: false
    property real brightness: 255
    property int lastValue: 255
    property int uiValue: 255
    property bool waitingToSend: true


    onEntityIdChanged: {
        if (!entityId || entityId === "") {
            console.log("No entityId yet, skipping fetch.")
            return
        }

        console.log("EntityId set:", entityId)

        Backend.getState(entityId, function(resp) {
            if (!resp) {
                console.error("getState: No response for", entityId)
                return
            }
            mySwitch.checked = resp.state == "on" ? true : false

        })
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        Kirigami.FormLayout {
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
        Switch {
            id: mySwitch
            Layout.fillWidth: true
            checked: false
            text: friendly_name
            onToggled: Backend.toggleEntity(entityId, checked)
        }
		PC3.Button {
			id: myButton2
			text: "Trigger"
			onClicked: Backend.trigger(entityId)
		}
        // Timer ensures we send max once every 0.5s
        Timer {
            id: sendDelay
            interval: 200 // ms
            repeat: true
            running: false
            onTriggered: {
                sendDelay.stop()

                waitingToSend = false
                if(interval == 1500)
                    interval = 200

            }
        }
    }

    WebSocket {
        id: haSocket
        url: haUrl.replace(/^http/, "ws") + "/api/websocket"
        active: true
        onStatusChanged: function(status) {
            if (status === WebSocket.Open) {
                console.log("WebSocket connected to Home Assistant")
                sendTextMessage(JSON.stringify({
                    type: "auth",
                    access_token: bearerToken
                }))
                sendTextMessage(JSON.stringify({
                    id: 1,
                    type: "subscribe_events",
                    event_type: "state_changed"
                }))
            }
        }
        function updateUIFromState(data, mySwitch) {
            if (data.entity_id.startsWith(entityId)) {
				mySwitch.checked = data.state == "on" ? true : false
                //sendDelay.start()
            }
        }
        onTextMessageReceived: (message) => {
            const data = JSON.parse(message)
            if (data.type === "event" && data.event?.data?.new_state)
                updateUIFromState(data.event.data.new_state, mySwitch)
        }
    }
}
