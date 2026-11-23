import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami
import "../../l10n"

// "Tessere": compact grid tile. Click the icon to toggle, the tile to open details.
PlasmaComponents3.ItemDelegate {
    id: tileRoot

    property string entityId: ""
    property var haManager: null
    property int cornerRadius: 12

    signal openDetailsRequested(string entId)

    EntityState {
        id: ent
        entityId: tileRoot.entityId
        haManager: tileRoot.haManager
    }

    padding: Kirigami.Units.smallSpacing * 1.5

    background: Rectangle {
        radius: tileRoot.cornerRadius
        color: ent.isOn
            ? Qt.alpha(Kirigami.Theme.highlightColor, tileRoot.hovered ? 0.32 : 0.22)
            : Qt.alpha(Kirigami.Theme.textColor, tileRoot.hovered ? 0.09 : 0.04)
        border.width: 1
        border.color: ent.isOn ? Qt.alpha(Kirigami.Theme.highlightColor, 0.70)
                    : Qt.alpha(Kirigami.Theme.textColor, tileRoot.hovered ? 0.16 : 0.08)
        Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }
    }

    onClicked: if (ent.cleanId) tileRoot.openDetailsRequested(ent.cleanId)

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: contextMenu.popup()
    }

    PlasmaComponents3.Menu {
        id: contextMenu
        PlasmaComponents3.MenuItem {
            text: ent.isFavorite ? Loc.t("Remove from favorites") : Loc.t("Add to favorites")
            icon.name: ent.isFavorite ? "non-starred-symbolic" : "starred-symbolic"
            onTriggered: ent.toggleFavorite()
        }
        PlasmaComponents3.MenuItem {
            text: Loc.t("Details")
            icon.name: "documentinfo"
            onTriggered: tileRoot.openDetailsRequested(ent.cleanId)
        }
    }

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing * 1.5

        EntityIcon {
            source: ent.iconUrl
            active: ent.isOn
            unavailable: ent.isUnavailable
            interactive: ent.isToggleable || ent.isActionable || ent.hasQuickToggle
            onClicked: ent.toggle()
            PlasmaComponents3.ToolTip.text: ent.isToggleable ? (ent.isOn ? Loc.t("Turn off") : Loc.t("Turn on")) : (ent.isActionable ? Loc.t("Run") : ent.quickToggleTooltip)
            PlasmaComponents3.ToolTip.visible: interactive && hoveredIcon.hovered
            HoverHandler { id: hoveredIcon }
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents3.Label {
                text: ent.title
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
                color: ent.isUnavailable ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
            }

            PlasmaComponents3.Label {
                text: ent.statusText
                font: Kirigami.Theme.smallFont
                color: ent.isOn ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                elide: Text.ElideRight
                maximumLineCount: 1
                Layout.fillWidth: true
            }
        }

        Kirigami.Icon {
            visible: ent.isFavorite
            source: "starred-symbolic"
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            color: Kirigami.Theme.highlightColor
            opacity: 0.8
            Layout.alignment: Qt.AlignTop
        }
    }
}
