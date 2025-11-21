// Shared helper for talking to Home Assistant REST API

function sendRequest(method, endpoint, data, callback) {
    const xhr = new XMLHttpRequest()
    xhr.open(method, haUrl + endpoint)
    console.log(haUrl + endpoint)
    xhr.setRequestHeader("Authorization", "Bearer " + bearerToken)
    xhr.setRequestHeader("Content-Type", "application/json")

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    callback(JSON.parse(xhr.responseText))
                } catch (e) {
                    console.error("Parse error", e, xhr.responseText)
                    callback(null)
                }
            } else {
                console.error("HTTP Error", xhr.status, xhr.responseText)
                callback(null)
            }
        }
    }

    if (data) xhr.send(JSON.stringify(data))
        else xhr.send()
}

//
// --- Entity Control Actions ---
//

// Generic toggle (for light/switch/input_boolean)
function toggleEntity(entityId, state) {
    const domain = entityId.split(".")[0]
    const service = state ? "turn_on" : "turn_off"
    sendRequest("POST", `/api/services/${domain}/${service}`, { entity_id: entityId }, function(resp) {
        console.log(`Toggled ${entityId} to ${state}`)
    })
}

// Light brightness
function setBrightness(entityId, value) {
    sendRequest("POST", "/api/services/light/turn_on", {
        entity_id: entityId,
        brightness: Math.round(value)
    }, function(resp) {
        console.log(`Set brightness for ${entityId} = ${value}`)
    })
}

// Input number
function setInputNumber(entityId, value) {
    sendRequest("POST", "/api/services/input_number/set_value", {
        entity_id: entityId,
        value: value
    }, function(resp) {})
}

// Input select
function setInputSelect(entityId, option) {
    sendRequest("POST", "/api/services/input_select/select_option", {
        entity_id: entityId,
        option: option
    }, function(resp) {})
}

// Media player
function mediaPlayPause(entityId) {
    sendRequest("POST", "/api/services/media_player/media_play_pause", { entity_id: entityId }, function(resp) {})
}
function setVolume(entityId, volume) {
    sendRequest("POST", "/api/services/media_player/volume_set", {
        entity_id: entityId,
        volume_level: volume
    }, function(resp) {})
}
// trigger Automation
function trigger(entityId) {
    const domain = entityId.split(".")[0]
    sendRequest("POST", `/api/services/${domain}/trigger`, { entity_id: entityId }, function(resp) {})
}
// Scene or script activation
function activate(entityId) {
    const domain = entityId.split(".")[0]
    sendRequest("POST", `/api/services/${domain}/turn_on`, { entity_id: entityId }, function(resp) {})
}

// Get current entity state
function getState(entityId, callback) {
    sendRequest("GET", "/api/states/" + entityId, null, callback)
}


function getBrightness(entityId, callback) {
    if (!entityId) {
        console.error("getBrightness: Missing entityId")
        if (callback) callback(null)
            return Promise.resolve(null)
    }

    return new Promise((resolve) => {
        getState(entityId, function(resp) {
            if (!resp) {
                console.error("getBrightness: No response for", entityId)
                if (callback) callback(null)
                    resolve(null)
                    return
            }

            let brightness = null
            if (resp.attributes && resp.attributes.brightness !== undefined) {
                brightness = resp.attributes.brightness
            } else {
                brightness = (resp.state === "on") ? 255 : 0
            }

            console.log(`getBrightness(${entityId}) ->`, brightness)

            if (callback) callback(brightness)
                resolve(brightness)
        })
    })
}



