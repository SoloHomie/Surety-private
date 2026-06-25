import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../baseComponents"
import "../toast"
import "market"

Rectangle {
    id: marketPage
    focus: true
    width: 1320; height: 936
    color: "#010409"
    clip: true

    property string searchText: ""
    property int    selectedIndex: -1

    // 外部详情（从 HeatRanking 跳转过来时使用）
    property var externalDetail: null
    readonly property bool _showDetail: selectedIndex >= 0 || externalDetail !== null

    function showExternalDetail(name, type, calls) {
        externalDetail = { name: name, type: type, calls: calls }
        selectedIndex = -1
    }

    function clearExternalDetail() { externalDetail = null }

    // ═══════════════════════════════════════════════
    //  搜索栏
    // ═══════════════════════════════════════════════
    SearchBar {
        id: searchBar
        anchors.left: parent.left;   anchors.leftMargin: 24
        anchors.right: parent.right; anchors.rightMargin: 24
        anchors.top: parent.top;     anchors.topMargin: 24
        text: marketPage.searchText
        onSearchTextChanged: marketPage.searchText = text
    }

    MouseArea { anchors.fill: parent; z: -1; onClicked: searchBar.clearFocus() }

    // ═══════════════════════════════════════════════
    //  主内容：Grid + 底部详情（向上展开）
    // ═══════════════════════════════════════════════
    ColumnLayout {
        anchors.left: parent.left;   anchors.leftMargin: 8
        anchors.right: parent.right; anchors.rightMargin: 8
        anchors.top: searchBar.bottom; anchors.topMargin: 12
        anchors.bottom: parent.bottom; anchors.bottomMargin: 8
        spacing: 0

        // ── 卡片网格（外部详情模式隐藏）──
        GridView {
            id: marketGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: externalDetail !== null ? 0 : undefined
            visible: externalDetail === null
            clip: true; cellWidth: itemW + 16; cellHeight: 160

            readonly property real itemW: Math.max(280, Math.floor(marketGrid.width / columns) - 16)
            readonly property int columns: Math.max(1, Math.floor(marketGrid.width / 360))

            model: MarketModel

            delegate: MarketItemDelegate {
                itemWidth:    marketGrid.itemW
                itemName:     model.mname
                itemType:     model.mtype
                itemColor:    model.mcolor; itemAuthor: model.mauthor
                description:  model.mdesc
                price:        model.mprice === "0" ? "Free" : ("¥" + model.mprice)
                pricingModel: model.mpricingModel
                callCount:    0
                isSelected:   marketPage.selectedIndex === index

                onClicked: {
                    var newIdx = (marketPage.selectedIndex === index) ? -1 : index
                    marketPage.selectedIndex = newIdx
                }
            }
        }

        // ── 详情面板（底部向上展开 / 收缩）──
        Rectangle {
            id: detailPanel
            Layout.fillWidth: true
            Layout.fillHeight: externalDetail !== null
            Layout.preferredHeight: externalDetail !== null ? 0
                : (marketPage._showDetail ? detailContent.implicitHeight + 24 : 0)
            color: "#0d1117"
            radius: 12

            // 分割线（展开时可见）
            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right
                anchors.top: parent.top
                height: 1; color: "#21262d"
                visible: detailPanel.height > 1
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            MarketDetailContent {
                id: detailContent
                anchors.left: parent.left;   anchors.leftMargin: 12
                anchors.right: parent.right; anchors.rightMargin: 12
                anchors.top: parent.top;     anchors.topMargin: 12

                itemName:      externalDetail !== null ? externalDetail.name  : sel.mname
                itemType:      externalDetail !== null ? externalDetail.type  : sel.mtype
                itemColor:     externalDetail !== null ? "#1f6feb"            : sel.mcolor
                itemAuthor:    externalDetail !== null ? ""                   : sel.mauthor
                description:   externalDetail !== null ? "来自热度排行榜"      : sel.mdesc
                version:       "1.0"
                oncePrice:     0
                subPrice:      0
                hasOnce:       true
                hasSub:        false

                onCloseRequested: {
                    marketPage.selectedIndex = -1
                    marketPage.externalDetail = null
                }
                onPurchaseRequested: function(model) {
                    marketPage.selectedIndex = -1
                    marketPage.externalDetail = null
                    ToastManager.add(
                        "<b>" + itemName + "</b> 已提交" + (model === "once" ? "买断" : "订阅"),
                        "success", "购买成功", 3000
                    )
                }
            }
        }
    }

    // ═══════════════════════════════════════════════
    //  选中项数据
    // ═══════════════════════════════════════════════
    readonly property var sel: {
        if (selectedIndex >= 0 && selectedIndex < MarketModel.rowCount()) {
            return MarketModel.get(selectedIndex)
        }
        return { name:"", type:"", icon:"", color:"#58A6FF", author:"", desc:"", price:"0", mname:"", mtype:"", mcolor:"", mauthor:"", mdesc:"", mprice:"0" }
    }
}
