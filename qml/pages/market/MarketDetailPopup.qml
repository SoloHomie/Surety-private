import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

//=============================================================================
// MarketDetailPopup — Agent 商品详情弹窗
//=============================================================================
Popup {
    id: root
    width: 520; padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay

    // ═══════════════════════════════════════════════
    //  数据
    // ═══════════════════════════════════════════════
    property string itemName:     ""
    property string itemType:     ""
    property string itemIcon:     ""
    property color  itemColor:    Theme.accent_text
    property string itemAuthor:   ""
    property string description:  ""
    property string price:        ""
    property string pricingModel: "once"
    property string version:      "1.0"
    property int    durationDays: 0
    property int    callCount:    0

    signal callRequested()

    // 当前选中的定价模式
    property string selectedPricing: root.pricingModel

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 240; easing.type: Easing.OutBack }
        }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
    }

    background: Rectangle {
        radius: 16; color: Theme.bg_card
        border.width: 1; border.color: Theme.border_standard
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ── 头部 ──
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 56
            color: "transparent"; radius: 16
            bottomLeftRadius: 0; bottomRightRadius: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20; anchors.rightMargin: 12

                Text {
                    text: root.itemName; color: Theme.text_primary
                    font.pixelSize: 22; font.weight: Font.DemiBold
                    font.family: "Microsoft YaHei UI"
                    Layout.fillWidth: true
                }
                SuretyBtn {
                    text: "×"; width: 28; height: 28; variant: "default"
                    font.pixelSize: 18; onClicked: root.close()
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border_default }

        // ── 内容 ──
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(detailBody.implicitHeight + 32, 500)
            contentHeight: detailBody.implicitHeight + 32
            clip: true; boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: SuretyScrollBar { }

            ColumnLayout {
                id: detailBody
                anchors.left: parent.left; anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20; anchors.topMargin: 20
                spacing: 20

                // ── 图标 + 基本信息 ──
                RowLayout {
                    spacing: 16
                    Rectangle {
                        width: 64; height: 64; radius: 14
                        color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.12)
                        Text {
                            anchors.centerIn: parent
                            text: root.itemName.charAt(0)
                            color: root.itemColor
                            font.pixelSize: 30; font.weight: Font.Bold; font.family: "Arial"
                        }
                    }
                    ColumnLayout {
                        spacing: 4
                        // 类型标签
                        Rectangle {
                            height: 22; radius: 6
                            width: tLabel.implicitWidth + 14
                            color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.15)
                            Text { id: tLabel; anchors.centerIn: parent; text: root.itemType
                                color: root.itemColor; font.pixelSize: 14; font.weight: Font.Bold
                                font.family: "JetBrains Mono" }
                        }
                        // 卖家 + 版本
                        Row {
                            spacing: 12
                            Text { visible: root.itemAuthor !== ""; text: "@" + root.itemAuthor
                                color: Theme.text_secondary; font.pixelSize: 14; font.family: "JetBrains Mono" }
                            Text { visible: root.version !== ""; text: "v" + root.version
                                color: Theme.text_hint; font.pixelSize: 13; font.family: "JetBrains Mono" }
                        }
                    }
                }

                // ── 描述 ──
                Text {
                    Layout.fillWidth: true
                    text: root.description; color: Theme.text_primary
                    font.pixelSize: 16; font.family: "Microsoft YaHei UI"
                    wrapMode: Text.WordWrap; lineHeight: 1.5
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border_default }

                // ── 定价方案 ──
                Text {
                    text: "定价方案"; color: Theme.text_primary
                    font.pixelSize: 18; font.weight: Font.DemiBold
                    font.family: "Microsoft YaHei UI"
                }

                // 定价模式显示（来自服务端数据）
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 64
                    radius: 10
                    color: Theme.bg_page
                    border.width: 1; border.color: Theme.border_standard

                    RowLayout {
                        anchors.centerIn: parent; spacing: 16
                        Rectangle {
                            height: 22; radius: 6
                            width: modelBadge.implicitWidth + 14
                            color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.15)
                            Text { id: modelBadge; anchors.centerIn: parent
                                text: root.pricingModel === "subscription" ? "订阅" : "买断"
                                color: root.itemColor; font.pixelSize: 14; font.weight: Font.Bold
                                font.family: "JetBrains Mono" }
                        }
                        Text {
                            text: root.pricingModel === "subscription"
                                  ? "每 " + root.durationDays + " 天自动续费"
                                  : "一次付费，永久拥有"
                            color: Theme.text_secondary; font.pixelSize: 15
                            font.family: "Microsoft YaHei UI"
                        }
                    }
                }

                // ── 价格显示 ──
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: {
                                var p = parseFloat(root.price) || 0
                                return p > 0 ? "¥" + p.toFixed(2) : "免费"
                            }
                            color: Theme.text_primary; font.pixelSize: 32; font.weight: Font.Bold
                            font.family: "JetBrains Mono"
                        }
                        Text {
                            visible: root.pricingModel === "subscription" && (parseFloat(root.price) || 0) > 0
                            text: "/ " + root.durationDays + " 天"
                            color: Theme.text_secondary; font.pixelSize: 14
                            font.family: "JetBrains Mono"
                        }
                    }
                    Item { Layout.fillWidth: true }
                    SuretyBtn {
                        text: "立即调用"; variant: "primary"; width: 120; height: 44
                        font.pixelSize: 17; font.weight: Font.Bold
                        onClicked: { root.callRequested(); root.close() }
                    }
                }
            }
        }
    }
}
