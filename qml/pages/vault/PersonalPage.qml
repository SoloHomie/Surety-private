import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"
import "../../toast"
import Surety 1.0
import "../../js/utils.js" as Utils

// 个人资产页 — 列表 + 可编辑详情
Rectangle {
    id: page
    color: "transparent"

    property int selectedIndex: -1
    property string _savingAssetId: ""
    signal assetSelected(int index)

    function getAsset(i) {
        if (!AssetModel || i < 0 || i >= AssetModel.count) return null
        return AssetModel.get(i)
    }

    // 保存后追踪资产重新选中
    Connections {
        target: AssetModel
        function onCountChanged() {
            if (_savingAssetId !== "") {
                // 保存后重新加载 → 找到刚保存的资产并选中
                for (var i = 0; i < AssetModel.count; i++) {
                    var item = AssetModel.get(i)
                    if (item && item.assetId === _savingAssetId) {
                        page.selectedIndex = i
                        _savingAssetId = ""
                        // 刷新详情
                        page.selectedIndexChanged()
                        return
                    }
                }
                _savingAssetId = ""
            }
            if (AssetModel.count > 0 && selectedIndex < 0)
                page.selectedIndex = 0
        }
    }

    RowLayout {
        anchors.fill: parent; spacing: 0

        // ── 左侧列表 ──
        Rectangle {
            Layout.preferredWidth: parent.width * 3 / 10
            Layout.fillHeight: true
            color: Theme.bg_input; radius: 12
            border.color: Theme.border_default; border.width: 1

            ListView {
                id: listView
                anchors.fill: parent; anchors.margins: 8
                clip: true; spacing: 6
                model: AssetModel

                delegate: AssetListDelegate {
                    delegateWidth: listView.width - 16
                    delegateIndex: index; delegateName: model.name
                    delegateType: model.type; delegateColor: model.code
                    delegateVersion: model.version
                    delegateSelected: page.selectedIndex === index
                    hasSubscription: false
                    visible: !model.hasSubscription
                    height: visible ? 64 : 0
                    onClicked: page.selectedIndex = (page.selectedIndex === index) ? -1 : index
                    onDeleteRequested: function(idx) {
                        var item = page.getAsset(idx)
                        if (item && item.assetId)
                            Assets.deleteAsset(Api.email, item.assetId)
                    }
                }
                ScrollBar.vertical: SuretyScrollBar {}
            }
        }

        // ── 右侧详情 ──
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.leftMargin: 20
            color: "transparent"

            AssetDetailPanel {
                id: detail
                anchors.fill: parent
                isReadOnly: false

                onSaveClicked: {
                    if (!Utils.checkLogin()) return
                    var item = page.getAsset(selectedIndex)
                    if (!item || !item.assetId) return
                    // 已上架资产需先下架再修改
                    if (item.quick === true) {
                        ToastManager.add(qsTr("资产已上架，请先下架后再修改"), "warning", qsTr("无法编辑"), 3000)
                        return
                    }
                    page._savingAssetId = item.assetId
                    var cur = { type: detail.selectedType, name: detail.nameText,
                                version: detail.versionText, desc: detail.descText,
                                oncePrice: "",
                                subPrice: detail.subPrice.trim(),
                                subDur: detail.subDuration.trim() }
                    Assets.updateAssetFull(Api.email, item.assetId, cur.type, cur.name,
                                           cur.desc, cur.version, cur.oncePrice, cur.subPrice, cur.subDur)
                }
            }
        }
    }

    // ── 选中变化 → 填充详情 ──
    onSelectedIndexChanged: {
        if (selectedIndex < 0) {
            detail.titleText = "---"
            detail.nameText = ""; detail.versionText = ""; detail.descText = ""; detail.typeIndex = 0
            detail.oncePrice = ""; detail.subPrice = ""; detail.subDuration = ""
            return
        }
        var item = page.getAsset(selectedIndex)
        if (!item) return
        detail.load(item)
        var onceP = parseFloat(item.once_price) || 0
        var subP  = parseFloat(item.sub_price)  || 0
        var subD  = parseInt(item.sub_duration_days) || 30
        detail.oncePrice   = onceP > 0 ? String(onceP) : ""
        detail.subPrice    = subP  > 0 ? String(subP)  : ""
        detail.subDuration = subP  > 0 ? String(subD)  : ""
    }
}
