// LightControl.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../code/backend.js" as Backend
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3



Item {
    id: root
    // make it expand properly in ColumnLayout
    Layout.fillWidth: true
    //Layout.preferredHeight: content.childrenRect.height + 10
    height: 40

    property string haUrl: plasmoid.configuration.homeAssistantUrl
    property string bearerToken: plasmoid.configuration.bearerToken


    property string entityId: ""
    property string friendly_name: ""
    property bool isOn: false
    property real brightness: 255
    property string value: ""



    onEntityIdChanged: {
        if (!entityId || entityId === "") {
            console.log("No entityId yet, skipping fetch.")
            return
        }

        console.log("EntityId set:", entityId)

        Backend.getState(entityId, function(resp) {
            if (!resp) {
                console.error("getBrightness: No response for", entityId)
                return
            }
            mySwitch.checked = resp.state == "on" ? true : false

        })
    }


    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
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
    }
}
