import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"
import Surety 1.0

// ═══════════════════════════════════════════════════════════════════════════════
//  AssetListPanel — 资产列表面板
//  Tab 0=个人, 1=订阅, 2=本地
//  每个 Tab 独立保存选中状态，切回时恢复；首次加载默认选第一项
// ═══════════════════════════════════════════════════════════════════════════════
Rectangle {
    id: root
    color: Theme.bg_input
    radius: 12
    border.color: Theme.border_default
    border.width: 1

    // ── 每 Tab 独立选中索引：[个人, 订阅, 本地] ──
    property var _selIdx: [-1, -1, -1]
    property int selectedIndex: _selIdx[root.tabIndex]
    property int selectedLocalIndex: _selIdx[2]
    property int tabIndex: 0
    property var model: null

    signal assetClicked(int index)
    signal manageClicked()
    signal localDraftClicked(int index)
    signal assetDeleteRequested(int index)

    // 外部更新选中（VaultPage 调用）
    function setSelectedIndex(idx) { _selIdx[root.tabIndex] = idx; _selIdx = _selIdx }
    function setSelectedLocalIndex(idx) { _selIdx[2] = idx; _selIdx = _selIdx }

    // 数据加载完成后默认选第一项
    function autoSelectIfNone() {
        var cur = _selIdx[root.tabIndex]
        if (cur >= 0) return
        var cnt = root.tabIndex === 2 ? _localDrafts.length : (root.model ? root.model.count : 0)
        if (cnt > 0) {
            _selIdx[root.tabIndex] = 0
            _selIdx = _selIdx
        }
    }

    // 外部可调
    function markDraftProcessed(filePath) {
        FileHelper.deleteFile(filePath)
        _refreshLocalDrafts()
    }
    function refreshLocal() { _refreshLocalDrafts() }

    function getAsset(i) {
        var m = root.model
        if (!m || i < 0 || i >= m.count) return null
        return m.get(i)
    }

    function getLocalDraft(i) {
        if (i < 0 || i >= _localDrafts.length) return null
        return _localDrafts[i]
    }

    // ── 头部（个人/订阅/本地切换）───────────────
    AssetListHeader {
        id: listHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16

        onTabChanged: function(idx) {
            // 保存当前 Tab 选中
            _selIdx[root.tabIndex] = (root.tabIndex === 2) ? _selIdx[2] : _selIdx[root.tabIndex]
            root.tabIndex = idx
            if (idx === 2) root._refreshLocalDrafts()
            root.autoSelectIfNone()
        }
        onManageClicked: root.manageClicked()
    }

    // ── 资产列表（个人 / 订阅共用）──
    ListView {
        id: assetListView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: listHeader.bottom
        anchors.bottom: parent.bottom
        focusPolicy: Qt.NoFocus
        anchors.topMargin: 8; anchors.bottomMargin: 8
        anchors.leftMargin: 8; anchors.rightMargin: 8
        clip: true
        spacing: 0

        model: root.model

        delegate: AssetListDelegate {
            delegateWidth:    assetListView.width
            delegateIndex:    index
            delegateName:     model.name
            delegateType:     model.type
            delegateColor:    model.code
            delegateVersion:  model.version
            delegateSelected: _selIdx[root.tabIndex] === index
            hasSubscription:  model.hasSubscription

            visible: root.tabIndex <= 1 ? (root.tabIndex === 0 ? !model.hasSubscription : model.hasSubscription) : false
            height:  visible ? 64 : 0

            onClicked: root.assetClicked(index)
            onDeleteRequested: root.assetDeleteRequested(index)
        }

        ScrollBar.vertical: SuretyScrollBar { }
    }

    // ── 本地草稿列表 ──
    property var _localDrafts: []

    function _refreshLocalDrafts() {
        _localDrafts = FileHelper.scanAllDrafts()
        // 列表刷新后默认选第一项
        if (_localDrafts.length > 0 && _selIdx[2] < 0)
            _selIdx[2] = 0
        _selIdx = _selIdx
    }

    Connections {
        target: AssetWatcher
        function onDraftsChanged() {
            if (root.tabIndex === 2) root._refreshLocalDrafts()
        }
    }

    ListView {
        id: localList
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: listHeader.bottom; anchors.bottom: parent.bottom
        anchors.topMargin: 8; anchors.bottomMargin: 8
        anchors.leftMargin: 8; anchors.rightMargin: 8
        visible: root.tabIndex === 2
        height: visible ? parent.height - listHeader.height - 16 : 0
        clip: true; spacing: 6
        model: root._localDrafts

        delegate: AssetListDelegate {
            delegateWidth:    localList.width
            delegateIndex:    index
            delegateName:     modelData.name || "未命名"
            delegateType:     modelData.type || "Skill"
            delegateColor:    modelData.color || Theme.accent_text
            delegateVersion:  modelData.version || "1.0"
            delegateSelected: _selIdx[2] === index
            hasSubscription:  false
            onClicked: root.localDraftClicked(index)
        }
    }
}
