import QtQuick
import "../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../baseComponents"
import "../toast"
import "market"
import Surety 1.0
import "../js/utils.js" as Utils

Rectangle {
    id: marketPage
    focus: true
    width: 1320; height: 936
    color: Theme.bg_input
    clip: true

    property string searchText: ""
    property int    selectedIndex: -1
    property var    _latestListing: null   // 最新拉取的详情（用于购买前验价）

    // 页面可见时刷新市场数据
    onVisibleChanged: { if (visible) Api.fetchListings() }

    // 订阅结果回调
    Connections {
        target: Api
        function onSubscribeFinished(ok, message) {
            if (ok) {
                ToastManager.add(qsTr("订阅成功！可在订阅页面查看"), "success", qsTr("操作成功"), 3000)
                marketPage.externalDetail = null
                marketPage._latestListing = null
                Api.fetchListings()
                Api.fetchBalance()
                Api.fetchTransactions()
                // 刷新订阅列表
                if (Api.isLoggedIn) { Assets.listSubscriptions(Api.email) }
            } else {
                ToastManager.add(message || "订阅失败", "error", "操作失败", 3000)
            }
        }
    }

    // 每 60 秒自动刷新（防止数据过期）
    Timer {
        id: refreshTimer
        interval: 60000; repeat: true; running: marketPage.visible
        onTriggered: Api.fetchListings()
    }

    Connections {
        target: Api
        function onListingDetailFetched(latest, cached) {
            if (!latest || Object.keys(latest).length === 0) {
                ToastManager.add(qsTr("该商品已下架或不存在"), "warning", qsTr("无法购买"), 3000)
                marketPage.selectedIndex = -1; marketPage._latestListing = null; return
            }
            marketPage._latestListing = latest
            marketPage.externalDetail = null  // 用最新数据替换热榜摘要
            if (cached && latest.subPrice !== undefined && cached.subPrice !== undefined) {
                if (Math.abs((latest.subPrice || 0) - (cached.subPrice || 0)) > 0.001) {
                    ToastManager.add(qsTr("价格已更新，请确认后再购买"), "info", qsTr("价格变动"), 3000)
                }
            }
        }
    }

    // 搜索防抖：输入停止 300ms 后触发服务端搜索
    Timer {
        id: searchDebounce
        interval: 300
        onTriggered: Api.fetchListings("", marketPage.searchText)
    }
    onSearchTextChanged: searchDebounce.restart()

    // 外部详情（从 HeatRanking 跳转过来时使用）
    property var externalDetail: null
    readonly property bool _showDetail: selectedIndex >= 0 || externalDetail !== null

    function showExternalDetail(listing) {
        if (!listing || !listing.listingId) return
        // 查找是否已在列表中
        var foundIdx = -1
        for (var i = 0; i < MarketModel.rowCount(); i++) {
            var row = MarketModel.get(i)
            if (row && row.listingId === listing.listingId) { foundIdx = i; break }
        }
        if (foundIdx >= 0) {
            // 已存在 → 直接选中
            selectedIndex = foundIdx
        } else {
            // 不存在 → 插队到第一位
            MarketModel.prependItem({
                name: listing.name || "", type: listing.type || "",
                color: "#C89B3C", desc: listing.desc || "",
                author: listing.author || "",
                oncePrice: listing.oncePrice || 0, subPrice: listing.subPrice || 0,
                subDuration: listing.subDuration || 30,
                listingId: listing.listingId, sellerId: listing.sellerId || "",
                version: "1.0"
            })
            selectedIndex = 0
        }
        // 拉取最新详情
        Api.fetchListingDetail(listing.listingId, {})
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
            Layout.preferredHeight: externalDetail !== null ? 0 : implicitHeight
            visible: externalDetail === null
            clip: true; cellWidth: itemW + 12; cellHeight: 160

            readonly property real itemW: Math.max(320, Math.floor(marketGrid.width / columns) - 12)
            readonly property int columns: Math.max(1, Math.floor(marketGrid.width / 480))

            model: MarketModel

            delegate: MarketItemDelegate {
                itemWidth:    marketGrid.itemW
                itemName:     model.mname
                itemType:     model.mtype
                itemColor:    model.mcolor; itemAuthor: model.mauthor
                description:  model.mdesc
                oncePrice:    model.moncePrice || 0
                subPrice:     model.msubPrice  || 0
                subDuration:  model.msubDuration || 30
                callCount:    0
                isSelected:   marketPage.selectedIndex === index
                isOwnAsset:   (model.msellerId || "") !== "" && model.msellerId === Api.uid

                onClicked: {
                    var newIdx = (marketPage.selectedIndex === index) ? -1 : index
                    marketPage.selectedIndex = newIdx
                    if (newIdx >= 0) {
                        var row = MarketModel.get(newIdx)
                        var cached = {
                            listingId: row.listingId, name: row.name, type: row.type,
                            oncePrice: row.oncePrice, subPrice: row.subPrice,
                            subDuration: row.subDuration, desc: row.desc
                        }
                        Api.fetchListingDetail(row.listingId, cached)
                    }
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
            color: Theme.bg_page
            radius: 12

            // 分割线（展开时可见）
            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right
                anchors.top: parent.top
                height: 1; color: Theme.border_default
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

                // 优先 _latestListing（服务端实时），兜底 sel（列表缓存）
                itemName:      externalDetail !== null ? (externalDetail.name || "") : ((marketPage._latestListing && marketPage._latestListing.name) || sel.name || "")
                itemType:      externalDetail !== null ? (externalDetail.type || "") : ((marketPage._latestListing && marketPage._latestListing.type) || sel.type || "")
                itemColor:     externalDetail !== null ? Theme.accent : (sel.color || Theme.accent_text)
                itemAuthor:    externalDetail !== null ? (externalDetail.author || "") : ((marketPage._latestListing && marketPage._latestListing.author) || sel.author || "")
                description:   externalDetail !== null ? (externalDetail.desc || "来自热度排行榜") : ((marketPage._latestListing && marketPage._latestListing.desc) || sel.desc || "暂无描述")
                version:       externalDetail !== null ? (externalDetail.version || "1.0") : ((marketPage._latestListing && marketPage._latestListing.version) || sel.version || "1.0")
                oncePrice:     externalDetail !== null ? (externalDetail.oncePrice || 0) : (marketPage._latestListing ? marketPage._latestListing.oncePrice  : (sel.oncePrice || 0))
                subPrice:      externalDetail !== null ? (externalDetail.subPrice || 0) : (marketPage._latestListing ? marketPage._latestListing.subPrice   : (sel.subPrice  || 0))
                subDuration:   externalDetail !== null ? (externalDetail.subDuration || 30) : (marketPage._latestListing ? marketPage._latestListing.subDuration : (sel.subDuration || 30))
                isOwnAsset:    externalDetail !== null
                    ? ((externalDetail.sellerId || "") !== "" && externalDetail.sellerId === Api.uid)
                    : ((sel.sellerId || "") !== "" && sel.sellerId === Api.uid)

                onCloseRequested: {
                    marketPage.selectedIndex = -1
                    marketPage.externalDetail = null
                }
                onPurchaseRequested: function(model) {
                    if (!Utils.checkLogin()) return
                    // 优先用 _latestListing，其次 sel
                    var row = marketPage._latestListing || MarketModel.get(marketPage.selectedIndex)
                    if (!row || !row.listingId) return

                    var sellerId = row.sellerId || ""
                    if (sellerId !== "" && sellerId === Api.uid) {
                        ToastManager.add(qsTr("这是你自己的资产哦~"), "warning", qsTr("无法购买"), 3000)
                        return
                    }

                    Api.subscribe(row.listingId)
                    marketPage.selectedIndex = -1
                    marketPage.externalDetail = null
                    marketPage._latestListing = null
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
        return { name:"", type:"", icon:"", color:"", author:"", desc:"", oncePrice:0, subPrice:0, subDuration:30, version:"1.0" }
    }

}
