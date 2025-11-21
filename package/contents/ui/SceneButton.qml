// SceneControl.qml
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
    height: 50

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
		PC3.Button {
			id: myButton
			text: friendly_name
			onClicked: Backend.activate(entityId)
		}
    }
}
