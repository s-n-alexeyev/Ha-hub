import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../services" as Services
import "components" as Components
import "../l10n"
import "../code/ha_helpers.js" as HAHelpers

PlasmoidItem {
    id: root

    Plasmoid.icon: Qt.resolvedUrl("../icons/home.svg")
    Plasmoid.title: "HA-Hub"

    // On the desktop we draw our own rounded, theme-tinted background so the
    // corner radius setting actually applies. In a panel popup Plasma draws the frame.
    readonly property bool onDesktop: Plasmoid.formFactor === PlasmaCore.Types.Planar
        || Plasmoid.formFactor === PlasmaCore.Types.MediaCenter
    Plasmoid.backgroundHints: onDesktop ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground

    // Keep the full view even when the widget is made small on the desktop
    switchWidth: Kirigami.Units.gridUnit * 9
    switchHeight: Kirigami.Units.gridUnit * 8

    toolTipMainText: (haManagerService && haManagerService.isConnected)
        ? (haManagerService.serverName || "Home Assistant")
        : "HA-Hub"

    toolTipSubText: {
        if (!haManagerService) return Loc.t("Disconnected");
        if (!haManagerService.isConnected) return haManagerService.connectionStatus || Loc.t("Disconnected");
        return Loc.t("Connected · %1 entities", haManagerService.entityCount);
    }

    readonly property string desktopEntityId: Plasmoid.configuration.desktopEntityId || ""
    readonly property string favoriteEntities: Plasmoid.configuration.favoriteEntities || ""

    function openConfiguration() {
        try {
            if (typeof Plasmoid.internalAction === "function") {
                var configAction = Plasmoid.internalAction("configure");
                if (configAction && typeof configAction.trigger === "function") {
                    configAction.trigger();
                    return;
                }
            }

            if (Plasmoid.contextualActions && Plasmoid.contextualActions.length > 0) {
                for (var i = 0; i < Plasmoid.contextualActions.length; i++) {
                    var act = Plasmoid.contextualActions[i];
                    if (act && (act.objectName === "configure" || (act.text && act.text.toLowerCase().indexOf("config") !== -1))) {
                        if (typeof act.trigger === "function") {
                            act.trigger();
                            return;
                        }
                    }
                }
            }
        } catch (e) {
            console.warn("HA-hub: Error opening settings:", e);
        }
    }

    // Hands the language saved in Settings to this engine's Loc singleton. The
    // singleton lives in the engine's root context and cannot see Plasma's
    // `Plasmoid`, so the configuration is handed to the bridge from here.
    Components.LanguageBridge {
        id: appletLanguageBridge
        configuration: Plasmoid.configuration
    }

    // The configuration reports only the keys its property map changes; a value
    // that moved while nobody was listening has to be asked for. Opening the
    // popup is that moment.
    onExpandedChanged: {
        if (root.expanded)
            appletLanguageBridge.recheck()
    }

    Services.HAManager {
        id: haManagerService
        host: Plasmoid.configuration.host || ""
        port: Plasmoid.configuration.port || 8123
        useSsl: Plasmoid.configuration.useSsl || false
        accessToken: Plasmoid.configuration.accessToken || ""
        serverName: Plasmoid.configuration.serverName || "Home Assistant"
    }

    Component.onCompleted: {
        // The helper functions translate strings that no Loc.t() call site can
        // name (a binary sensor's state is chosen from the entity's class), so
        // the translator is handed to the plain .js helper as a function.
        if (typeof HAHelpers.setTranslator === "function") {
            HAHelpers.setTranslator(function(text, args) {
                return Loc.t.apply(Loc, [text].concat(args || []));
            });
        }
        haManagerService.startAutoConnect();
    }

    compactRepresentation: CompactRepresentation {
        haManager: haManagerService
        onClicked: root.expanded = !root.expanded
    }

    fullRepresentation: FullRepresentation {
        haManager: haManagerService
        drawOwnBackground: root.onDesktop
        favoriteEntities: root.favoriteEntities
        onConfigureRequested: root.openConfiguration()
    }
}
