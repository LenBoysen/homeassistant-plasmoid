import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

Kirigami.ScrollablePage {
    readonly property alias cfg_showAll: showAllBool.checked
    property alias cfg_selectedEntities: selectedEntitiesString.text
    //property string cfg_selectedEntitiesf

    function fetchEntities() {
        // Load from config values in General group
        const url = plasmoid.configuration.homeAssistantUrl
        const token = plasmoid.configuration.bearerToken
        if (!url || !token) {
            console.log("Please configure URL and token first.")
            return
        }

        const xhr = new XMLHttpRequest()
        xhr.open("GET", url + "/api/states")
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    entityList.clear()
                    const data = JSON.parse(xhr.responseText)

                    // sort alphabetically by friendly name or entity_id
                    data.sort((a, b) => {
                        const nameA = (a.attributes.friendly_name || a.entity_id).toLowerCase()
                        const nameB = (b.attributes.friendly_name || b.entity_id).toLowerCase()
                        return nameA.localeCompare(nameB)
                    })

                    for (let i = 0; i < data.length; ++i) {
                        const entity = data[i]
                        entityList.append({
                            entity_id: entity.entity_id,
                            friendly_name: entity.attributes.friendly_name || entity.entity_id,
                            state: entity.state,
                            domain: entity.entity_id.split(".")[0],
                            raw: entity  // keep full raw object in case you need it later
                        })
                    }
                    console.log("Fetched " + data.length + " entities.")
                } else {
                    console.log("Error fetching entities:", xhr.status)
                }
            }
        }
        xhr.send()
    }
    function isEntitySelected(entityId) {
        for (let i = 0; i < selectedList.count; ++i) {
            if (selectedList.get(i).text === entityId)
                return true;
        }
        return false;
    }

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Entities"
		}
		PC3.CheckBox {
			id: showAllBool
			checked: false
            Kirigami.FormData.label: "Show unsuported"
			onCheckedChanged: {
				console.log("Checkbox is now", checked)
			}
		}
        Button {
            id: fetchButton
            Layout.preferredWidth: 300
            text: "Fetch Entities"
            onClicked: fetchEntities()
        }

        ListModel { id: entityList }
        ListModel { id: selectedList }


        // ONLY FOR DEBUGGING
        TextField {
            id: selectedEntitiesString
            text: ""
            visible: true
            clip: true
        }

        // Search filter
        TextField {
            id: searchField
            Kirigami.FormData.label: "Search"
            placeholderText: "Type to regex filter entities..."
            //onTextChanged: filteredModel.filterRegularExpression = RegExp(searchField.text, "i")
        }
        KItemModels.KSortFilterProxyModel {
            id: filteredModel
            sourceModel: entityList
            sortRoleName: "text"                 // Sort alphabetically by text
            filterRoleName: "text"               // Filter by the same role
			// Dynamically update the filter based on the checkbox
			filterRegularExpression: RegExp(
				// require category match unless showAllBool is checked
				(showAllBool.checked ? "" : "(?=.*^((light)|(switch)|(automation)|(script)|(scene)|(input_number)|(input_boolean)))") +
				// require search match
				"(?=.*" + searchField.text + ")" +
				// match everything
				".*",
				"i"
			)
		}



        ColumnLayout {
            Kirigami.FormData.label: i18n("Available Entities")
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.smallSpacing

            ScrollView {
                id: scroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 250   // <-- important: ensures visible area
                clip: true

                ListView {
                    id: availableList
                    model: filteredModel
                    anchors.fill: parent
                    clip: true
                    delegate: ItemDelegate {
                        width: ListView.view ? ListView.view.width : 200
                        text: model.entity_id
                        onClicked: {
                            //if (!isEntitySelected(model.entity_id))
                            selectedList.append({
                                entity_id: model.entity_id,
                                friendly_name: model.friendly_name || model.entity_id,
                                state: model.state || "",
                                domain: model.domain || model.entity_id.split(".")[0],
                                raw: model.raw || {}
                            })

                        }
                    }
                }
            }
        }
        Kirigami.Separator { Layout.fillWidth: true }


        ColumnLayout {
            Kirigami.FormData.label: i18n("Selected Entities")
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.smallSpacing
            //wideMode: true

            ScrollView {
                id: scroll2
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: false


                ListView {
                    id: chosenList
                    model: selectedList
                    clip: false
                    delegate: RowLayout {
                        Button {
                            icon.name: "go-up"
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            padding: 2
                            onClicked: {
                                const i = index
                                if (i > 0) {
                                    selectedList.insert(i - 1, selectedList.get(i))
                                    selectedList.remove(i + 1)
                                }
                            }
                        }
                        Button {
                            icon.name: "go-down"
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            padding: 2
                            onClicked: {
                                const i = index
                                if (i < selectedList.count - 1) {
                                    selectedList.insert(i + 2, selectedList.get(i))
                                    selectedList.remove(i)
                                }
                            }
                        }
                        Button {
                            icon.name: "edit-delete"
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            padding: 2
                            onClicked: selectedList.remove(index)
                        }
                        Label {
                            text: model.friendly_name //model.entity_id
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
        Component.onCompleted: {
            const saved = cfg_selectedEntities
            selectedList.clear()
            console.log("Selected: ", saved)
            if (saved && saved.length > 0) {
                try {
                    const entities = JSON.parse(saved)
                    for (let i = 0; i < entities.length; ++i) {
                        const e = entities[i]
                        console.log("e.entity_id: ")
                        console.log(e.entity_id)
                        selectedList.append({
                            entity_id: e.entity_id,
                            friendly_name: e.friendly_name || e.entity_id,
                            state: e.state || "",
                            domain: e.domain || e.entity_id.split(".")[0],
                            raw: e.raw || {}
                        })
                    }
                    console.log("Loaded", entities.length, "saved entities.")
                } catch (err) {
                    console.log("Error parsing saved entities:", err)
                }
            }

            fetchEntities()
        }
        Connections {
            target: selectedList

            function onCountChanged() {
                // Collect all entity data from selectedList
                let arr = []
                for (let i = 0; i < selectedList.count; ++i) {
                    const e = selectedList.get(i)
                    arr.push({
                        entity_id: e.entity_id,
                        friendly_name: e.friendly_name || e.entity_id,
                        state: e.state || "",
                        domain: e.domain || (e.entity_id ? e.entity_id.split(".")[0] : ""),
                        raw: e.raw || {}
                    })
                }

                // Save as JSON string to configuration
                cfg_selectedEntities = JSON.stringify(arr)
                console.log("Saved", arr.length, "entities to config.")
            }
        }
    }
}
