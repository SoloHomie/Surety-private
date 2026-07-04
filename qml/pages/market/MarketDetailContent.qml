import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

// 市场商品详情 — 适用于上架资产浏览与购买
Item {
    id: root
    implicitHeight: contentLayout.implicitHeight
    implicitWidth:  1000

    // ── 外部数据 ──────────────────────────────────────
    property string itemName:      ""
    property string itemType:      ""
    property string itemIcon:      ""
    property color  itemColor:     Theme.accent_text
    property string itemAuthor:    ""
    property string description:   ""
    property string version:       "1.0"

    // 定价
    property double oncePrice:     0      // 买断价格（0=免费买断）
    property double subPrice:      0      // 订阅价格（0=不提供）
    property int    subDuration:   30     // 订阅周期（天）

    // 买断总是可用（至少兜底免费）；订阅仅当价格>0时可用
    readonly property bool hasSub:  subPrice > 0
    readonly property bool hasBoth: hasSub   // TagSelector 仅在订阅也提供时显示

    // MVP: 仅订阅模式
    property string selectedModel: "subscription"
    property bool   isOwnAsset: false

    signal purchaseRequested(string model)
    signal closeRequested()

    // ═══════════════════════════════════════════════════
    //  内容
    // ═══════════════════════════════════════════════════
    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        spacing: 12

        // ── 标题栏 ──
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.itemName || "Untitled"
                color: Theme.text_primary
                font.pixelSize: 22; font.weight: Font.DemiBold
                font.family: "Microsoft YaHei UI"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            SuretyBtn {
                text: "×"; width: 32; height: 32; variant: "default"
                font.pixelSize: 18
                onClicked: root.closeRequested()
            }
        }

        // ── 基本信息 ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Avatar {
                width: 48; height: 48; radius: 12
                name: root.itemName; accentColor: root.itemColor
                bgOpacity: 0.12; fontSize: 28; fontFamily: "Arial"
            }

            ColumnLayout {
                spacing: 6
                Layout.fillWidth: true

                Row {
                    spacing: 10
                    Rectangle {
                        height: 24; radius: 6
                        width: typeBadge.implicitWidth + 14
                        color: Theme.tag_preset_bg
                        Text {
                            id: typeBadge
                            anchors.centerIn: parent
                            text: root.itemType; color: Theme.tag_preset_fg
                            font.pixelSize: 15; font.weight: Font.Bold
                            font.family: "JetBrains Mono"
                        }
                    }
                    Text {
                        visible: root.itemAuthor !== ""
                        text: root.itemAuthor; color: Theme.text_secondary
                        font.pixelSize: 15; font.family: "Microsoft YaHei UI"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        visible: root.version !== ""
                        text: "v" + root.version; color: Theme.text_hint
                        font.pixelSize: 14; font.family: "JetBrains Mono"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border_default }

        // ── 描述 ──
        Text {
            Layout.fillWidth: true
            text: root.description || "暂无描述。"
            color: root.description !== "" ? Theme.text_primary : Theme.text_disabled
            font.pixelSize: 16; font.family: "Microsoft YaHei UI"
            wrapMode: Text.WordWrap; lineHeight: 1.5
            maximumLineCount: 6; elide: Text.ElideRight
        }

        // ═══════════════════════════════════════════════════
        //  定价（两者都有 → SuretyTagSelector 切换 / 仅一种 → 直接展示）
        // ═══════════════════════════════════════════════════

        // MVP: 仅订阅，隐藏买断/订阅切换

        // ── 价格卡片 ──
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 64
            radius: 10; color: Theme.bg_page
            border.width: 1; border.color: Theme.border_default

            RowLayout {
                anchors.centerIn: parent; spacing: 12
                Rectangle {
                    height: 22; radius: 6; width: priceTag.implicitWidth + 14
                    color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.15)
                    Text { id: priceTag; anchors.centerIn: parent
                        text: "订阅"
                        color: root.itemColor; font.pixelSize: 14; font.weight: Font.Bold
                        font.family: "JetBrains Mono" }
                }
                Text {
                    text: root.subPrice > 0 ? "¥" + root.subPrice.toFixed(0) + " / " + root.subDuration + "天" : "免费订阅"
                    color: Theme.text_primary; font.pixelSize: 24; font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                }
            }
        }

        // ── 购买按钮（自有资产隐藏）──
        SuretyBtn {
            visible: !root.isOwnAsset
            Layout.fillWidth: true
            Layout.topMargin: 4; height: 44
            text: root.subPrice > 0 ? "立即订阅 · ¥" + root.subPrice.toFixed(0) + " / " + root.subDuration + "天" : "免费订阅"
            variant: "primary"
            font.pixelSize: 18; font.weight: Font.Bold
            onClicked: root.purchaseRequested(root.selectedModel)
        }
    }
}
