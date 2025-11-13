/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami




Kirigami.ScrollablePage {
    property alias cfg_homeAssistantUrl: homeAssistantUrl.text
    property alias cfg_bearerToken: bearerToken.text
    Kirigami.FormLayout {

        Kirigami.FormLayout {
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "Server"
            }
            TextField {
                id: homeAssistantUrl
                placeholderText: "http://10.1.1.38:8123"
                Kirigami.FormData.label: "Home Assistant URL"
            }
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "Credentials"
            }
            TextField {
                id: bearerToken
                echoMode: TextInput.Password
                placeholderText: "Paste your token here"
                Kirigami.FormData.label: "Bearer Token"
            }

        }
    }
}
