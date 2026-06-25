import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

// ═══════════════════════════════════════════════════════════════════════════════
//  AssetListPanel — 资产列表面板
// ═══════════════════════════════════════════════════════════════════════════════
Rectangle {
    id: root
    color: "#010409"
    radius: 12
    border.color: "#21262d"
    border.width: 1

    property int    selectedIndex: -1
    property var model: null

    signal assetClicked(int index)
    signal manageClicked()

    function getAsset(i) {
        var m = root.model
        if (!m || i < 0 || i >= m.count) return null
        return m.get(i)
    }

    // ── 头部（个人/订阅切换 + 管理按钮）───────────────
    property alias tabIndex: listHeader.tabIndex

    AssetListHeader {
        id: listHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16

        onTabChanged: function(idx) { root.tabIndex = idx }
        onManageClicked: root.manageClicked()
    }

    // ── 资产列表 ──
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
            delegateSelected: root.selectedIndex === index
            hasSubscription:  model.hasSubscription

            // 过滤：个人 tab → 非订阅资产；订阅 tab → SUB 资产
            visible: root.tabIndex === 0 ? !model.hasSubscription : model.hasSubscription
            height:  visible ? 64 : 0

            onClicked: root.assetClicked(index)
        }

        ScrollBar.vertical: SuretyScrollBar { }
    }
}
