import QtQuick
import org.kde.plasma.configuration

import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM


ConfigModel {
    ConfigCategory {
        name: i18n('General')
        icon: 'preferences-desktop-color'
        source: 'config/ConfigGeneral.qml'
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-display-color"
        source: "config/ConfigAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Behavior")
        icon: "preferences-desktop"
        source: "config/ConfigBehavior.qml"
    }
}
