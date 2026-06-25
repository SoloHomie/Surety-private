import QtQuick
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
    property color  itemColor:    "#58A6FF"
    property string itemAuthor:   ""
    property string description:  ""
    property string price:        ""
    property string pricingModel: "perCall"
    property int    callCount:    0
    property real   rating:       0.0
    property bool   isFavorited:  false

    signal callRequested()
    signal favorited()

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
        radius: 16; color: "#161b22"
        border.width: 1; border.color: "#30363d"
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
                    text: root.itemName; color: "#e6edf3"
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

        Rectangle { Layout.fillWidth: true; height: 1; color: "#21262d" }

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
                        Row {
                            spacing: 8
                            Rectangle {
                                height: 22; radius: 6; width: tLabel.implicitWidth + 14
                                color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.15)
                                Text { id: tLabel; anchors.centerIn: parent; text: root.itemType
                                    color: root.itemColor; font.pixelSize: 14; font.weight: Font.Bold
                                    font.family: "JetBrains Mono" }
                            }
                            Text { visible: root.itemAuthor !== ""; text: root.itemAuthor
                                color: "#6e7681"; font.pixelSize: 14; font.family: "Microsoft YaHei UI" }
                        }
                        Row {
                            spacing: 12
                            Row {
                                spacing: 2
                                Repeater {
                                    model: 5
                                    Text {
                                        text: index < Math.floor(root.rating) ? "★" : "☆"
                                        color: index < root.rating ? "#d29922" : "#484f58"
                                        font.pixelSize: 15
                                    }
                                }
                            }
                            Text {
                                visible: root.callCount > 0
                                text: root.callCount + " 次调用"; color: "#6e7681"
                                font.pixelSize: 14; font.family: "JetBrains Mono"
                            }
                        }
                    }
                }

                // ── 描述 ──
                Text {
                    Layout.fillWidth: true
                    text: root.description; color: "#c9d1d9"
                    font.pixelSize: 16; font.family: "Microsoft YaHei UI"
                    wrapMode: Text.WordWrap; lineHeight: 1.5
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#21262d" }

                // ── 定价模式选择 ──
                Text {
                    text: "定价模式"; color: "#e6edf3"
                    font.pixelSize: 18; font.weight: Font.DemiBold
                    font.family: "Microsoft YaHei UI"
                }

                RowLayout {
                    spacing: 10
                    Repeater {
                        model: [
                            { mode: "once",      label: "一次性付费", desc: "买断永久使用" },
                            { mode: "perCall",   label: "按次调用",   desc: "每次调用计费" },
                            { mode: "subscribe", label: "订阅服务",   desc: "按月自动续费" },
                        ]
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 64
                            radius: 10
                            color: root.selectedPricing === modelData.mode ? "#0d419d" : "#0d1117"
                            border.width: root.selectedPricing === modelData.mode ? 1 : 1
                            border.color: root.selectedPricing === modelData.mode ? "#1f6feb" : "#21262d"
                            Behavior on color { ColorAnimation { duration: 150 } }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedPricing = modelData.mode
                            }

                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 4
                                Text {
                                    text: modelData.label; color: "#e6edf3"
                                    font.pixelSize: 16; font.weight: Font.DemiBold
                                    font.family: "Microsoft YaHei UI"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: modelData.desc; color: "#8b949e"
                                    font.pixelSize: 14; font.family: "Microsoft YaHei UI"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }

                // ── 价格显示 ──
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.price === "Free" ? "免费" : (root.price + " ETH")
                        color: "#e6edf3"; font.pixelSize: 32; font.weight: Font.Bold
                        font.family: "JetBrains Mono"
                    }
                    Text {
                        visible: root.price !== "Free" && root.price !== ""
                        text: root.selectedPricing === "once" ? "一次性" :
                              (root.selectedPricing === "subscribe" ? "/ 月" : "/ 次")
                        color: "#6e7681"; font.pixelSize: 15
                        font.family: "Microsoft YaHei UI"
                        anchors.verticalCenter: parent.verticalCenter
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
