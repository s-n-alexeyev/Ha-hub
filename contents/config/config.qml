pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.configuration
import org.kde.plasma.plasmoid
import "../l10n"
import "../ui/components" as Components

ConfigModel {
    // The section names are translated, and this file runs in the settings
    // dialog's engine before any page of it exists - so the list needs a bridge
    // of its own, hung off a property because everything written in the body of
    // a ConfigModel is taken for one of its categories. Where the configuration
    // cannot be seen from here the bridge stays quiet, and the names keep the
    // language they had before.
    property QtObject languageBridge: Components.LanguageBridge {
        configuration: (typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.configuration)
            ? Plasmoid.configuration : null
    }

    ConfigCategory {
        name: Loc.t("General")
        icon: "network-server-symbolic"
        source: "settings/ConfigGeneral.qml"
    }
    ConfigCategory {
        name: Loc.t("Favorite devices")
        icon: "starred-symbolic"
        source: "settings/ConfigFavorites.qml"
    }
}
