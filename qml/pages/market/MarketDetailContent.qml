import QtQuick
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
    property color  itemColor:     "#58A6FF"
    property string itemAuthor:    ""
    property string description:   ""
    property string version:       "1.0"

    // 定价
    property double oncePrice:     0      // 永久买断价格
    property double subPrice:      0      // 订阅价格
    property int    subDuration:   30     // 订阅周期（天）
    property bool   hasOnce:       true   // 是否有买断选项
    property bool   hasSub:        true   // 是否有订阅选项

    // 选中的方案: "once" | "subscription"
    property string selectedModel: root.hasOnce ? "once" : "subscription"

    signal purchaseRequested(string model)   // model: "once" | "subscription"
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
                color: "#e6edf3"
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
                        color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.15)
                        Text {
                            id: typeBadge
                            anchors.centerIn: parent
                            text: root.itemType; color: root.itemColor
                            font.pixelSize: 15; font.weight: Font.Bold
                            font.family: "JetBrains Mono"
                        }
                    }
                    Text {
                        visible: root.itemAuthor !== ""
                        text: root.itemAuthor; color: "#8b949e"
                        font.pixelSize: 15; font.family: "Microsoft YaHei UI"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        visible: root.version !== ""
                        text: "v" + root.version; color: "#6e7681"
                        font.pixelSize: 14; font.family: "JetBrains Mono"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#21262d" }

        // ── 描述 ──
        Text {
            Layout.fillWidth: true
            text: root.description || "暂无描述。"
            color: root.description !== "" ? "#c9d1d9" : "#484f58"
            font.pixelSize: 16; font.family: "Microsoft YaHei UI"
            wrapMode: Text.WordWrap; lineHeight: 1.5
            maximumLineCount: 6; elide: Text.ElideRight
        }

        // ── 购买方案选择 ──
        Text {
            text: "购买方案"
            color: "#8b949e"
            font.pixelSize: 14; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI"
        }

        SuretyTagSelector {
            id: modelSelector
            width: 300
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            displayMode: "segment"
            segmentHeight: 40; segmentRadius: 6

            model: {
                var items = []
                if (root.hasOnce) items.push({ label: "永久买断" })
                if (root.hasSub)  items.push({ label: "订阅" })
                return items
            }

            selectedIndex: root.selectedModel === "once" ? 0
                         : (root.hasOnce ? 1 : 0)

            onTagSelected: function(idx) {
                if (root.hasOnce && root.hasSub)
                    root.selectedModel = idx === 0 ? "once" : "subscription"
                else if (root.hasOnce)
                    root.selectedModel = "once"
                else
                    root.selectedModel = "subscription"
            }
        }

        // ── 价格卡片 ──
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 4
            color: "#0d1117"
            radius: 10
            border.width: 1; border.color: "#21262d"
            height: priceCardContent.implicitHeight + 40

            ColumnLayout {
                id: priceCardContent
                anchors.left: parent.left;   anchors.leftMargin: 24
                anchors.right: parent.right; anchors.rightMargin: 24
                anchors.top: parent.top;     anchors.topMargin: 20
                spacing: 8

                // 价格
                Text {
                    text: root.selectedModel === "once"
                          ? (root.oncePrice > 0 ? "¥" + root.oncePrice.toFixed(2) : "免费")
                          : (root.subPrice > 0 ? "¥" + root.subPrice.toFixed(2) : "免费")
                    color: "#e6edf3"
                    font.pixelSize: 32; font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                }

                // 周期
                Text {
                    visible: root.selectedModel === "subscription"
                    text: "/ " + root.subDuration + " 天"
                    color: "#8b949e"
                    font.pixelSize: 15
                    font.family: "JetBrains Mono"
                }

                // 方案标签 + 说明
                RowLayout {
                    spacing: 10
                    Rectangle {
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: badgeText.implicitWidth + 16
                        radius: 6
                        color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.12)
                        Text {
                            id: badgeText
                            anchors.centerIn: parent
                            text: root.selectedModel === "once" ? "永久买断" : "订阅制"
                            color: root.itemColor
                            font.pixelSize: 13; font.weight: Font.Bold
                            font.family: "Microsoft YaHei UI"
                        }
                    }

                    Text {
                        text: root.selectedModel === "once" ? "一次付费，永久拥有" : "到期自动续费，可随时取消"
                        color: "#6e7681"
                        font.pixelSize: 13
                        font.family: "Microsoft YaHei UI"
                    }
                }
            }
        }

        // ── 购买按钮（独立一行，全宽）──────────────────
        SuretyBtn {
            Layout.fillWidth: true
            Layout.topMargin: 4
            height: 44
            text: root.selectedModel === "once" ? "立即购买" : "立即订阅"
            variant: "primary"
            font.pixelSize: 18; font.weight: Font.Bold
            onClicked: root.purchaseRequested(root.selectedModel)
        }
    }
}
