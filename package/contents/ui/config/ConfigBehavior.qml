import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    readonly property alias cfg_filterByScreen: filterByScreenChk.checked

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Info Filtering"
        }
        PC3.CheckBox{
            id: filterByScreenChk
            Kirigami.FormData.label: i18n("Show only from current screen:")
        }
    }
}
