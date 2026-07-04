import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"
import "../../toast"
import Surety 1.0
import "../../js/utils.js" as Utils

// 本地草稿页 — 列表 + 审阅后保存
Rectangle {
    id: page
    color: "transparent"

    property int selectedIndex: -1
    property var drafts: []

    function refreshDrafts() {
        drafts = FileHelper.scanAllDrafts()
        if (drafts.length > 0 && selectedIndex < 0)
            selectedIndex = 0
        else if (drafts.length === 0)
            selectedIndex = -1
    }

    // Agent 实时产出
    Connections {
        target: AssetWatcher
        function onDraftsChanged() { page.refreshDrafts() }
    }

    Component.onCompleted: refreshDrafts()

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
                model: page.drafts

                delegate: AssetListDelegate {
                    delegateWidth: listView.width - 16
                    delegateIndex: index; delegateName: modelData.name || "未命名"
                    delegateType: modelData.type || "Skill"; delegateColor: modelData.color || Theme.accent_text
                    delegateVersion: modelData.version || "1.0"
                    delegateSelected: page.selectedIndex === index
                    hasSubscription: false
                    showDelete: false
                    onClicked: page.selectedIndex = (page.selectedIndex === index) ? -1 : index
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
                saveBtnText: "创建资产"

                onSaveClicked: {
                    if (!Utils.checkLogin()) return
                    var cur = { type: detail.selectedType, name: detail.nameText,
                                version: detail.versionText, desc: detail.descText,
                                oncePrice: "",
                                subPrice: detail.subPrice.trim(),
                                subDur: detail.subDuration.trim() }
                    Assets.createAssetFull(Api.email, cur.type, cur.name, cur.desc, cur.version,
                                           cur.oncePrice, cur.subPrice, cur.subDur)
                }
            }
        }
    }

    // ── 选中变化 → 填充详情 ──
    onSelectedIndexChanged: {
        if (selectedIndex < 0 || selectedIndex >= drafts.length) {
            detail.titleText = "---"
            detail.nameText = ""; detail.versionText = ""; detail.descText = ""; detail.typeIndex = 0
            detail.oncePrice = ""; detail.subPrice = ""; detail.subDuration = ""
            return
        }
        var d = drafts[selectedIndex]
        detail.titleText   = d.name  || "新资产"
        detail.nameText    = d.name  || ""
        detail.versionText = d.version || "1.0"
        detail.descText    = d.description || ""
        detail.oncePrice   = ""
        detail.subPrice    = ""
        detail.subDuration = ""
        detail.selectType(d.type || "Skill")
    }

    // ── 保存成功 → 移到 personal + 刷新 ──
    Connections {
        target: Assets
        function onAssetCreated(ok) {
            if (ok) {
                var idx = selectedIndex
                if (idx >= 0 && idx < drafts.length) {
                    var d = drafts[idx]
                    var ft = d.filePath || ""
                    var at = d.type || "Skill"
                    if (ft) FileHelper.moveToPersonal(ft, at)
                }
                page.refreshDrafts()
                ToastManager.add(qsTr("资产创建成功，已加入你的资产库"), "success", qsTr("保存成功"), 2500)
            }
        }
    }
}
