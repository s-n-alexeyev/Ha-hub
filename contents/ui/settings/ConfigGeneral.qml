pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import "../../l10n"
import "../../ui/components" as Components

Kirigami.ScrollablePage {
    id: generalSettings
    title: Loc.t("General")
    topPadding: 0

    // This dialog has its own Loc instance: without a language pushed into it,
    // every page here stays in the system language. The page hands over the
    // language it was opened with - the dialog's copy of the configuration,
    // `cfg_language`, which arrives exactly like every other setting here. That
    // is also why the dialog and the widget cannot disagree: the widget reads the
    // same configuration, and Apply writes into it.
    Components.LanguageBridge {
        id: settingsLanguageBridge
        pendingLanguage: generalSettings.cfg_language
    }

    readonly property string cfg_hostDefault: "192.168.1.100"
    readonly property string cfg_portDefault: "8123"
    readonly property bool cfg_useSslDefault: false
    readonly property string cfg_accessTokenDefault: ""
    readonly property bool cfg_autoConnectDefault: true
    readonly property string cfg_serverNameDefault: "Home Assistant"
    readonly property string cfg_favoriteEntitiesDefault: "[]"
    readonly property string cfg_viewModeDefault: "rows"
    // The language the widget paints in: "system" follows the desktop. Declared
    // in main.xml next to the other settings, so the dialog stores it the same way.
    readonly property string cfg_languageDefault: "system"
    readonly property int cfg_cornerRadiusDefault: 16
    readonly property int cfg_backgroundOpacityDefault: 70

    property string cfg_host: "192.168.1.100"
    property string cfg_port: "8123"
    property bool cfg_useSsl: false
    property string cfg_accessToken: ""
    property bool cfg_autoConnect: true
    property string cfg_serverName: "Home Assistant"
    property string cfg_favoriteEntities: "[]"
    property string cfg_viewMode: "rows"
    property string cfg_language: "system"
    property int cfg_cornerRadius: 16
    property int cfg_backgroundOpacity: 70
    // Keys edited elsewhere; declared so the config dialog doesn't warn
    property int cfg_lastTab
    property int cfg_lastTabDefault
    property int cfg_panelDisplayMode
    property int cfg_panelDisplayModeDefault
    property string cfg_primarySensorEntity
    property string cfg_primarySensorEntityDefault
    property string cfg_desktopEntityId
    property string cfg_desktopEntityIdDefault
    property bool cfg_showDashboard
    property bool cfg_showDashboardDefault

    // One way to change the language, used by the picker: into cfg_language, the
    // value the dialog was opened with and Apply stores. The dialog repaints with
    // it at once through the bridge above - a dialog that changed language only on
    // Apply would be unreadable in a language the user cannot read yet.
    //
    // One writer: the page. A write that goes around the dialog's own copy of the
    // configuration is undone when the dialog closes and its copy is written back.
    function selectLanguage(code) {
        if (code === generalSettings.cfg_language && Loc.configuredLanguage === code) return
        generalSettings.cfg_language = code
    }

    Kirigami.FormLayout {
        id: formLayout
        Layout.fillWidth: true

        Kirigami.Separator {
            Kirigami.FormData.label: Loc.t("Home Assistant connection")
            Kirigami.FormData.isSection: true
        }

        Controls.TextField {
            id: hostField
            Kirigami.FormData.label: Loc.t("Home Assistant host / IP:")
            placeholderText: "homeassistant.local or 192.168.1.100"
            text: generalSettings.cfg_host
            Layout.fillWidth: true
            onTextEdited: generalSettings.cfg_host = text
        }

        Controls.TextField {
            id: portField
            Kirigami.FormData.label: Loc.t("Port:")
            placeholderText: "8123"
            text: generalSettings.cfg_port
            inputMethodHints: Qt.ImhDigitsOnly
            onTextEdited: generalSettings.cfg_port = text
        }

        Controls.CheckBox {
            id: sslCheckBox
            Kirigami.FormData.label: Loc.t("Secure connection:")
            text: Loc.t("Use wss:// (HTTPS)")
            checked: generalSettings.cfg_useSsl
            onToggled: generalSettings.cfg_useSsl = checked
        }

        Controls.TextField {
            id: tokenField
            Kirigami.FormData.label: Loc.t("Long-lived access token:")
            placeholderText: Loc.t("Long-lived token (Profile → Security in Home Assistant)")
            text: generalSettings.cfg_accessToken
            echoMode: TextInput.Password
            Layout.fillWidth: true
            onTextEdited: generalSettings.cfg_accessToken = text
        }

        Controls.CheckBox {
            id: autoConnectCheckBox
            Kirigami.FormData.label: Loc.t("Auto-connect:")
            text: Loc.t("Connect on startup")
            checked: generalSettings.cfg_autoConnect
            onToggled: generalSettings.cfg_autoConnect = checked
        }

        Controls.ComboBox {
            id: languageCombo
            objectName: "languageCombo"
            Kirigami.FormData.label: Loc.t("Language:")
            Layout.fillWidth: true

            // The model carries only what never changes: the codes and the
            // names each language writes about itself. A translated string
            // inside the model would rebuild the model at the very moment the
            // language changes (the picker retranslates as it picks), and the
            // control resets its currentIndex when the model is swapped.
            readonly property var entries: [{ code: "system" }].concat(Loc.languages)
            readonly property string systemLabel: Loc.t("System language")
            model: entries
            textRole: "code"

            function labelFor(code) {
                if (code === "system") return languageCombo.systemLabel
                var langs = Loc.languages
                for (var k = 0; k < langs.length; ++k) {
                    if (langs[k].code === code) return langs[k].label
                }
                return code
            }
            function indexForCode(code) {
                for (var k = 0; k < entries.length; ++k) {
                    if (entries[k].code === code) return k
                }
                return 0
            }

            currentIndex: indexForCode(generalSettings.cfg_language)
            // Translated on its own, so switching language retranslates the
            // button and the list without touching the model.
            displayText: currentIndex >= 0 && currentIndex < entries.length
                ? languageCombo.labelFor(entries[currentIndex].code) : ""

            delegate: Controls.ItemDelegate {
                required property var modelData
                required property int index
                width: languageCombo.width
                text: languageCombo.labelFor(modelData.code)
                highlighted: languageCombo.highlightedIndex === index
                onClicked: {
                    // A pick is a pick, wherever it came from. Writing popup.closed
                    // used to live here, and since that property is read-only the
                    // assignment threw a TypeError that stopped the handler before
                    // the language was ever handed over: the list looked dead.
                    languageCombo.currentIndex = index
                    languageCombo.popup.dismiss()
                    generalSettings.selectLanguage(modelData.code)
                }
            }

            // Keyboard navigation in the popup ends here instead of in a delegate
            // click. selectLanguage ignores a pick of the language already set.
            onActivated: (index) => generalSettings.selectLanguage(entries[index].code)
        }

        // The language is painted the moment it is picked, but like every other
        // setting it is only stored on Apply - and a page cannot store it itself.
        Controls.Label {
            text: Loc.t("Apply to keep this language after closing the settings.")
            font: Kirigami.Theme.smallFont
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Kirigami.Separator {
            Kirigami.FormData.label: Loc.t("Appearance")
            Kirigami.FormData.isSection: true
        }

        Controls.ComboBox {
            id: viewModeBox
            Kirigami.FormData.label: Loc.t("Default view:")
            model: [
                { text: Loc.t("Rows"), value: "rows" },
                { text: Loc.t("Tiles"), value: "tiles" },
                { text: Loc.t("Cards (Liquid Glass)"), value: "cards" }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                if (generalSettings.cfg_viewMode === "tiles") return 1;
                if (generalSettings.cfg_viewMode === "cards") return 2;
                return 0;
            }
            onActivated: {
                generalSettings.cfg_viewMode = model[currentIndex].value;
            }
        }

        RowLayout {
            Kirigami.FormData.label: Loc.t("Corner radius:")
            spacing: Kirigami.Units.smallSpacing

            Controls.Slider {
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                from: 0
                to: 32
                stepSize: 1
                value: generalSettings.cfg_cornerRadius
                onMoved: generalSettings.cfg_cornerRadius = Math.round(value)
            }
            Controls.SpinBox {
                from: 0
                to: 32
                value: generalSettings.cfg_cornerRadius
                textFromValue: function(v) { return v + " px"; }
                valueFromText: function(t) { return parseInt(t); }
                onValueModified: generalSettings.cfg_cornerRadius = value
            }
        }

        RowLayout {
            Kirigami.FormData.label: Loc.t("Background opacity:")
            spacing: Kirigami.Units.smallSpacing

            Controls.Slider {
                Layout.fillWidth: true
                Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                from: 0
                to: 100
                stepSize: 5
                value: generalSettings.cfg_backgroundOpacity
                onMoved: generalSettings.cfg_backgroundOpacity = Math.round(value)
            }
            Controls.SpinBox {
                from: 0
                to: 100
                stepSize: 5
                value: generalSettings.cfg_backgroundOpacity
                textFromValue: function(v) { return v + " %"; }
                valueFromText: function(t) { return parseInt(t); }
                onValueModified: generalSettings.cfg_backgroundOpacity = value
            }
        }

        Controls.Label {
            text: Loc.t("Corner radius and opacity apply when the widget is on the desktop; in a panel, Plasma draws the popup frame. Colors always follow the system theme.")
            wrapMode: Text.WordWrap
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
        }
    }
}
