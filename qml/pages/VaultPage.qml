import QtQuick
import "../themes"
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "vault"
import "../toast"

Rectangle {
    id: vaultPage; focus: true; width: 1320; height: 936; color: Theme.bg_input; clip: true

    property int tabIndex: 0

    function loadAll() {
        if (Api.isLoggedIn) {
            Assets.listAssets(Api.email, "")
            Assets.listSubscriptions(Api.email)
        }
    }

    Connections {
        target: Api
        function onAuthChanged() { if (Api.isLoggedIn) loadAll() }
    }

    Connections {
        target: Assets
        function onAssetsLoaded(json) { AssetModel.loadFromJson(json, false); Api.updateLocalStats() }
        function onSubscriptionsLoaded(json) { SubModel.loadFromJson(json, true); Api.updateLocalStats() }
        function onAssetCreated(ok, assetId, msg) {
            if (ok) loadAll()
            else ToastManager.add(msg, "error", "保存失败", 3000)
        }
        function onAssetUpdated(ok, msg) {
            if (ok) {
                loadAll()
                var label = msg.indexOf("deleted") >= 0 ? "已删除" : "已更新"
                ToastManager.add(label, "success", "操作成功", 2500)
            } else ToastManager.add(msg, "error", "操作失败", 3000)
        }
    }

    // Agent 产出 → 跳到本地页
    Connections {
        target: AssetWatcher
        function onDraftDiscovered(draft) {
            vaultPage.tabIndex = 2
            localPage.refreshDrafts()
            ToastManager.add("\"" + (draft.name || "新资产") + "\" 已导入，请审核后保存", "info", "Agent 产出", 4000)
        }
    }

    Component.onCompleted: { if (Api.isLoggedIn) loadAll() }

    // ── Tab 头部 ──
    AssetListHeader {
        id: header
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16

        onTabChanged: function(idx) {
            vaultPage.tabIndex = idx
            if (idx === 2) localPage.refreshDrafts()
        }
        onManageClicked: manageDrawer.open()
    }

    // ── 三页面切换 ──
    StackLayout {
        id: stack
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: header.bottom; anchors.bottom: parent.bottom
        anchors.margins: 24
        currentIndex: vaultPage.tabIndex

        PersonalPage  { id: personalPage }
        SubscribedPage { id: subscribedPage }
        LocalPage      { id: localPage }
    }

    ManageDrawer { id: manageDrawer; parentHeight: vaultPage.height; model: AssetModel }
}
