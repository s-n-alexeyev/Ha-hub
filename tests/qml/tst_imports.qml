import QtQuick
import QtTest
import "../../contents/l10n"

// Regression test for "Type X unavailable" / "Script file ... unavailable"
// runtime errors: every file of the applet must link cleanly, including its
// relative JS imports and nested types.
//
// The list is the applet: `git ls-files contents` plus the files the language
// layer added. A file missing from it is a file nothing checks, which is how a
// broken relative import used to survive to the moment someone clicked the widget.
TestCase {
    name: "ComponentLinking"

    property var chain: [
        "../../contents/config/config.qml",
        "../../contents/services/HAManager.qml",
        "../../contents/services/HAStatisticsService.qml",
        "../../contents/services/MDNSDiscovery.qml",
        "../../contents/ui/CompactRepresentation.qml",
        "../../contents/ui/FullRepresentation.qml",
        "../../contents/ui/components/CompactDeviceRow.qml",
        "../../contents/ui/components/CompactDeviceTile.qml",
        "../../contents/ui/components/DeviceCard.qml",
        "../../contents/ui/components/EntityIcon.qml",
        "../../contents/ui/components/EntityState.qml",
        "../../contents/ui/components/GlassDeviceCard.qml",
        "../../contents/ui/components/LanguageBridge.qml",
        "../../contents/ui/components/MarqueeLabel.qml",
        "../../contents/ui/components/NativeDeviceItem.qml",
        "../../contents/ui/details/DeviceDetailsPage.qml",
        "../../contents/ui/main.qml",
        "../../contents/ui/settings/ConfigFavorites.qml",
        "../../contents/ui/settings/ConfigGeneral.qml",
        "../../contents/ui/views/AuthWizardView.qml",
        "../../contents/ui/views/DeviceListView.qml",
        "../../contents/ui/views/HeaderView.qml",
        "../../contents/ui/details/sections/AlarmControlPanelSection.qml",
        "../../contents/ui/details/sections/BinarySensorSection.qml",
        "../../contents/ui/details/sections/CameraSection.qml",
        "../../contents/ui/details/sections/ClimateSensorSection.qml",
        "../../contents/ui/details/sections/CoverSection.qml",
        "../../contents/ui/details/sections/DeviceInfoSection.qml",
        "../../contents/ui/details/sections/DeviceOptionsSection.qml",
        "../../contents/ui/details/sections/FanSection.qml",
        "../../contents/ui/details/sections/GenericSection.qml",
        "../../contents/ui/details/sections/HumidifierSection.qml",
        "../../contents/ui/details/sections/LawnMowerSection.qml",
        "../../contents/ui/details/sections/LightSection.qml",
        "../../contents/ui/details/sections/LockSection.qml",
        "../../contents/ui/details/sections/MediaPlayerSection.qml",
        "../../contents/ui/details/sections/PersonSection.qml",
        "../../contents/ui/details/sections/PlugSection.qml",
        "../../contents/ui/details/sections/SirenSection.qml",
        "../../contents/ui/details/sections/SwitchSection.qml",
        "../../contents/ui/details/sections/ThermostatSection.qml",
        "../../contents/ui/details/sections/VacuumSection.qml",
        "../../contents/ui/details/sections/ValveSection.qml",
        "../../contents/ui/details/sections/WaterHeaterSection.qml",
        "../../contents/ui/details/sections/WeatherSection.qml"
    ]

    function test_all_ui_components_link() {
        var failures = []
        for (var i = 0; i < chain.length; i++) {
            var url = Qt.resolvedUrl(chain[i])
            var comp = Qt.createComponent(url, Component.Asynchronous)
            var waited = 0
            while (comp.status === Component.Loading && waited < 5000) {
                wait(25)
                waited += 25
            }
            if (comp.status !== Component.Ready) {
                failures.push(chain[i] + " => " + comp.errorString())
            }
        }
        compare(failures.join("\n"), "")
    }

    // Collect every text rendered inside an object tree.
    function collectTexts(item, out) {
        if (!item) return out
        if (typeof item.text === "string" && item.text.length > 0) out.push(item.text)
        var kids = item.children || []
        for (var i = 0; i < kids.length; i++) collectTexts(kids[i], out)
        return out
    }

    // Linking a component does not evaluate its bindings, so a view that
    // forgets `import "../../l10n"` still links but throws
    // "Loc is not defined" as soon as it is created. Build the parts that need
    // nothing from the outside - the header, the empty device list, the general
    // settings page - and check a translated string really reached them.
    function test_views_render_localized_text() {
        Loc.forcedLanguage = "ru"
        var built = []
        var failures = []
        var sources = [
            "../../contents/ui/views/HeaderView.qml",
            "../../contents/ui/views/DeviceListView.qml",
            "../../contents/ui/settings/ConfigGeneral.qml"
        ]
        for (var i = 0; i < sources.length; i++) {
            var comp = Qt.createComponent(Qt.resolvedUrl(sources[i]))
            if (comp.status !== Component.Ready) {
                failures.push(sources[i] + " => " + comp.errorString())
                continue
            }
            var item = comp.createObject(null)
            if (!item) {
                failures.push(sources[i] + " => created nothing")
                continue
            }
            built.push(item)
        }
        wait(50)
        compare(failures.join("\n"), "")

        var texts = []
        for (var j = 0; j < built.length; j++) texts = collectTexts(built[j], texts)
        // "Home Assistant connection" is a heading of the general page, translated
        // like everything else: an English heading here means that page has no
        // language, which is the bug the bridge exists to fix.
        verify(texts.indexOf(Loc.t("Home Assistant connection")) !== -1,
               "no translated text was rendered: " + JSON.stringify(texts))
        verify(texts.indexOf(Loc.t("Home Assistant connection"))
               !== "Home Assistant connection",
               "the heading came out in English")

        for (var k = 0; k < built.length; k++) built[k].destroy()
        Loc.forcedLanguage = ""
    }
}
