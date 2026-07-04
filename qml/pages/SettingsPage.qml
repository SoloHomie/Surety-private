import QtQuick
import "../themes"
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "settings"

Rectangle {
    id: settingsPage
    width: 1320
    height: 936
    color: Theme.bg_input
    clip: true

    property string currentPage: "general"

    // ═══════════════════════════════════════════════════
    //  顶部导航栏
    // ═══════════════════════════════════════════════════
    SettingsNavBar {
        id: navBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 24

        currentPage: settingsPage.currentPage
        onPageChanged: settingsPage.currentPage = page
    }

    // ═══════════════════════════════════════════════════
    //  共享子页面插槽 — opacity 淡入/淡出，状态不丢失
    // ═══════════════════════════════════════════════════
    component SubPageSlot: Item {
        anchors.fill: parent
        property bool active: false

        opacity: active ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    }

    // ═══════════════════════════════════════════════════
    //  内容区
    // ═══════════════════════════════════════════════════
    Rectangle {
        id: contentArea
        color: Theme.bg_page
        radius: 10
        border.color: Theme.border_default
        border.width: 1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: navBar.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 20
        anchors.bottomMargin: 24
        clip: true

        SubPageSlot { active: settingsPage.currentPage === "general";     SettingsGeneral    { anchors.fill: parent } }
        SubPageSlot { active: settingsPage.currentPage === "appearance";  SettingsAppearance { anchors.fill: parent } }
        SubPageSlot { active: settingsPage.currentPage === "advanced";    SettingsAdvanced   { anchors.fill: parent } }
        SubPageSlot { active: settingsPage.currentPage === "about";       SettingsAbout      { anchors.fill: parent } }
        SubPageSlot { active: settingsPage.currentPage === "beta";        SettingsBeta       { anchors.fill: parent } }
        SubPageSlot { active: settingsPage.currentPage === "wallet";      WalletPage         { anchors.fill: parent } }
    }
}
