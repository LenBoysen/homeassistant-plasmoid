// InputNumberControl.qml
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
    height: 60

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
		Backend.getState(entityId, function(data) {
			console.log(JSON.stringify(data))
			mySlider.from = data.attributes.min
			mySlider.to = data.attributes.max
			mySlider.stepSize = data.attributes.step
			mySlider.value = parseInt(data.state)
			waitingToSend = false
		})
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        Kirigami.FormLayout {
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
		Label {
			text: friendly_name
		}

        PC3.Slider {
            id: mySlider
            Layout.fillWidth: true
            //visible: isOn
            from: 0; to: 255
            value: 0

            stepSize: 1

            // internal state variable
            property bool userIsChanging: false
            property int userValue: value // will hold only user-set value
            onPressedChanged: function(status) {
                if (pressed) {
                    userIsChanging = true
                } else {
                    userIsChanging = false
                    userValue = value
                    console.log(entityId, waitingToSend,  mySlider.value, lastValue, userValue)
                    console.log("User finished sliding ->", userValue)

                    if(userValue != lastValue){
                        lastValue = userValue
                        mySlider.value = userValue
						mySwitch.checked = userValue == 0 ? false : true
						
                        Backend.setInputNumber(entityId, value)
                        waitingToSend = true
                        console.log(entityId, "set value:", userValue)
                        sendDelay.interval = 1500
                        sendDelay.start()
                    }
                }
            }
            onMoved: {
                if (userIsChanging) {
                    userValue = value
                    console.log("User moving slider:", userValue)
                    if(waitingToSend == false){
                        lastValue = userValue
                        mySlider.value = userValue
                        Backend.setInputNumber(entityId, value)
                        waitingToSend = true
                        console.log(entityId, "set value:", userValue)
                        sendDelay.start()
                    }
                }
            }

            onValueChanged: {
            }
        }
        // Timer ensures we send max once every 0.5s
        Timer {
            id: sendDelay
            interval: 200 // ms
            repeat: true
            running: false
            onTriggered: {
                sendDelay.stop()

                console.log(entityId, waitingToSend,  mySlider.value, lastValue, uiValue)

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
        function updateUIFromState(data, mySlider) {
            // Example: light brightness → slider
			if (data.entity_id.startsWith(entityId) && waitingToSend == false) {
				waitingToSend = true
				mySlider.from = data.attributes.min
				mySlider.to = data.attributes.max
				mySlider.stepSize = data.attributes.step
				mySlider.value = parseInt(data.state)
                waitingToSend = false
                //sendDelay.start( 
            }
        }
        onTextMessageReceived: (message) => {
            const data = JSON.parse(message)
            if (data.type === "event" && data.event?.data?.new_state)
                updateUIFromState(data.event.data.new_state, mySlider)
        }
    }
}
