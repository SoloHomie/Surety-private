import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "vault"
import "../toast"

Rectangle {
    id: vaultPage; focus: true; width: 1320; height: 936; color: "#010409"; clip: true
    readonly property real _gap: 68
    readonly property real _availW: vaultPage.width - _gap
    // 当前编辑中的资产 ID（为空 = 新建模式）
    property string _editingAssetId: ""
    // 保存加载时的原始数据，用于脏检查
    property var _originalData: null

    function loadAll() { if (Api.isLoggedIn) { Assets.listAssets(Api.email, ""); Assets.listSubscriptions(Api.email) } }

    function _submitPricing(assetId) {
        var onceP = detailPanel.oncePrice.trim()
        if (onceP !== "") Assets.addPricing(assetId, "once", onceP, "0")
        var subP = detailPanel.subPrice.trim()
        if (subP !== "") Assets.addPricing(assetId, "subscription", subP, detailPanel.subDuration.trim() || "30")
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
            if (ok) { _submitPricing(assetId); _editingAssetId = ""; _originalData = null; loadAll(); ToastManager.add("资产已创建", "success", "保存成功", 2500) }
            else ToastManager.add(msg, "error", "保存失败", 3000)
        }
        function onAssetUpdated(ok, msg) {
            if (ok) { _submitPricing(vaultPage._editingAssetId); loadAll(); ToastManager.add("资产已更新", "success", "更新成功", 2500) }
            else ToastManager.add(msg, "error", "更新失败", 3000)
        }
    }
    Component.onCompleted: { if (Api.isLoggedIn) loadAll() }

    AssetListPanel {
        id: listPanel
        width: Math.floor(vaultPage._availW * 3 / 10)
        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
        anchors.leftMargin: 24; anchors.topMargin: 24; anchors.bottomMargin: 24
        model: listPanel.tabIndex === 0 ? AssetModel : SubModel

        onAssetClicked: function(idx) { vaultPage._selectAsset(idx) }
        onManageClicked: manageDrawer.open()
    }

    AssetDetailPanel {
        id: detailPanel
        anchors.left: listPanel.right; anchors.right: parent.right
        anchors.top: parent.top; anchors.bottom: parent.bottom
        anchors.leftMargin: 20; anchors.rightMargin: 24
        anchors.topMargin: 24; anchors.bottomMargin: 24
        onSaveClicked: {
            // ── 脏检查：没有修改则跳过 ──
            var cur = { type: detailPanel.selectedType, name: detailPanel.nameText,
                        version: detailPanel.versionText, desc: detailPanel.descText }
            var orig = vaultPage._originalData
            if (orig && cur.type === orig.type && cur.name === orig.name
                     && cur.version === orig.version && cur.desc === orig.desc) {
                ToastManager.add("没有修改，无需保存", "info", "提示", 2000)
                return
            }

            if (vaultPage._editingAssetId === "") {
                Assets.createAsset(Api.email, cur.type, cur.name, cur.desc, cur.version)
            } else {
                Assets.updateAsset(Api.email, vaultPage._editingAssetId, cur.type, cur.name, cur.desc, cur.version)
            }
        }
    }

    ManageDrawer { id: manageDrawer; parentHeight: vaultPage.height; model: AssetModel }

    function _selectAsset(idx) {
        if (listPanel.selectedIndex === idx) {
            listPanel.selectedIndex = -1; detailPanel.titleText = "---"
            detailPanel.nameText = ""; detailPanel.versionText = ""; detailPanel.descText = ""; detailPanel.typeIndex = 0
            vaultPage._editingAssetId = ""; vaultPage._originalData = null; return
        }
        listPanel.selectedIndex = idx
        var item = listPanel.getAsset(idx)
        detailPanel.load(item)
        vaultPage._editingAssetId = item.assetId || ""
        vaultPage._originalData = {
            type: item.type || "",
            name: item.name || "",
            version: item.version || "",
            desc: item.desc || ""
        }
    }
}
