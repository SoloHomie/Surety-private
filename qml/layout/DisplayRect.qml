import QtQuick
import QtQuick.Controls
import "../pages"

Rectangle {
    id: displayRect
    width: 1320
    height: 936
    color: "#010409"
    bottomRightRadius: 10
    topLeftRadius: 0
    clip: true

    // ═══════════════════════════════════════════════════
    //  页面索引 + 方向感知
    // ═══════════════════════════════════════════════════
    property int pageIndex: 0
    property int previousIndex: 0

    readonly property int _dir: pageIndex > previousIndex ? 1 : (pageIndex < previousIndex ? -1 : 0)

    function switchTo(idx) {
        if (idx === pageIndex) return
        previousIndex = pageIndex
        pageIndex = idx
    }

    // ═══════════════════════════════════════════════════
    //  页面过渡动画计算
    // ═══════════════════════════════════════════════════
    function xFor(pageIdx) {
        if (pageIdx === displayRect.pageIndex) return 0
        if (pageIdx === displayRect.previousIndex && _dir !== 0)
            return _dir > 0 ? -40 : 40
        return pageIdx < displayRect.pageIndex ? -24 : 24
    }

    function opacityFor(pageIdx) {
        return pageIdx === displayRect.pageIndex ? 1 : 0
    }

    function scaleFor(pageIdx) {
        return pageIdx === displayRect.pageIndex ? 1.0 : 0.97
    }

    // ═══════════════════════════════════════════════════
    //  共享动画插槽 — fade + directional slide 统一
    // ═══════════════════════════════════════════════════
    component AnimatedSlot: Item {
        anchors.fill: parent
        property real targetOpacity: 1
        property real targetX: 0
        property real targetScale: 1.0

        opacity: targetOpacity
        x: targetX
        scale: targetScale
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on x       { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    }

    // ═══════════════════════════════════════════════════
    //  页面
    // ═══════════════════════════════════════════════════
    AnimatedSlot {
        targetOpacity: displayRect.opacityFor(0)
        targetX: displayRect.xFor(0)
        targetScale: displayRect.scaleFor(0)
        HomePage {
            anchors.fill: parent
            onMarketItemRequested: function(name, type, calls) {
                displayRect.showMarketDetail(name, type, calls)
            }
        }
    }

    AnimatedSlot {
        targetOpacity: displayRect.opacityFor(1)
        targetX: displayRect.xFor(1)
        targetScale: displayRect.scaleFor(1)
        VaultPage { anchors.fill: parent }
    }

    AnimatedSlot {
        targetOpacity: displayRect.opacityFor(2)
        targetX: displayRect.xFor(2)
        targetScale: displayRect.scaleFor(2)
        MarketPage {
            id: marketPage
            anchors.fill: parent
        }
    }

    AnimatedSlot {
        targetOpacity: displayRect.opacityFor(3)
        targetX: displayRect.xFor(3)
        targetScale: displayRect.scaleFor(3)
        SettingsPage { anchors.fill: parent }
    }

    // 供外部调用：导航到市场页并展示指定详情
    function showMarketDetail(name, type, calls) {
        marketPage.showExternalDetail(name, type, calls)
        switchTo(2)
    }
}
