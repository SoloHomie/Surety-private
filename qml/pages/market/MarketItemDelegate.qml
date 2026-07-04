import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

//=============================================================================
// MarketItemDelegate — Agent 市场卡片
//=============================================================================
Rectangle {
    id: root
    width:  itemWidth
    height: 144
    radius: 12

    // ═══════════════════════════════════════════════
    //  外观
    // ═══════════════════════════════════════════════
    property color cardBg:        Theme.bg_page
    property color cardBgHover:   Theme.bg_card
    property color cardBorder:    Theme.border_default
    property color cardBorderHov: Theme.border_standard
    property color cardBorderSel: Theme.accent
    property color cardBgSel:     Theme.bg_card
    property color titleColor:    Theme.text_primary
    property color descColor:     Theme.text_secondary
    property color statColor:     Theme.text_hint
    // ═══════════════════════════════════════════════
    //  数据
    // ═══════════════════════════════════════════════
    property string itemName:     ""
    property string itemType:     ""
    property string itemIcon:     ""
    property color  itemColor:    Theme.accent_text
    property string itemAuthor:   ""
    property string description:  ""
    property double oncePrice:     0
    property double subPrice:      0
    property int    subDuration:   30
    property int    callCount:     0
    property bool   isSelected:   false
    property bool   isOwnAsset:   false
    property int    itemWidth:    460

    signal clicked()
    signal callRequested()

    readonly property bool _hov: hoverMA.containsMouse

    color: isSelected ? cardBgSel : (_hov ? cardBgHover : cardBg)
    border.width: isSelected ? 2 : 1
    border.color: isSelected ? cardBorderSel : (_hov ? cardBorderHov : cardBorder)
    Behavior on color        { ColorAnimation { duration: 180 } }
    Behavior on border.color { ColorAnimation { duration: 180 } }
    Behavior on border.width { NumberAnimation { duration: 150 } }

    // ── 选中指示条 ──
    Rectangle {
        anchors.left: parent.left; anchors.leftMargin: -1
        anchors.top: parent.top;   anchors.topMargin: 5
        anchors.bottom: parent.bottom; anchors.bottomMargin: 5
        width: 3; radius: 2
        color: root.cardBorderSel
        opacity: root.isSelected ? 1 : 0
        scale: root.isSelected ? 1 : 0.6
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
    }

    MouseArea {
        id: hoverMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    // ═══════════════════════════════════════════════
    //  内容
    // ═══════════════════════════════════════════════
    RowLayout {
        anchors.left:   parent.left;   anchors.leftMargin: 20
        anchors.right:  parent.right;  anchors.rightMargin: 20
        anchors.top:    parent.top;    anchors.topMargin: 20
        anchors.bottom: parent.bottom; anchors.bottomMargin: 20
        spacing: 16

        // ── 图标 ──
        Rectangle {
            width: 60; height: 60; radius: 14
            color: Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.12)
            Layout.alignment: Qt.AlignTop

            Image {
                visible: root.itemIcon !== ""
                anchors.centerIn: parent; width: 34; height: 34
                source: root.itemIcon; fillMode: Image.PreserveAspectFit
            }
            Text {
                visible: root.itemIcon === ""
                anchors.centerIn: parent
                text: root.itemName.charAt(0)
                color: root.itemColor
                font.pixelSize: 32; font.weight: Font.Bold; font.family: "Arial"
            }
        }

        // ── 信息区 ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            // 名称
            Text {
                Layout.fillWidth: true
                text: root.itemName; color: root.titleColor
                font.pixelSize: 20; font.weight: Font.DemiBold
                font.family: "Microsoft YaHei UI"
                elide: Text.ElideRight; maximumLineCount: 1
            }

            // 描述
            Text {
                Layout.fillWidth: true
                visible: root.description !== ""
                text: root.description; color: root.descColor
                font.pixelSize: 16; font.family: "Microsoft YaHei UI"
                elide: Text.ElideRight; maximumLineCount: 1
                lineHeight: 1.3
            }

            // 标签 + 统计
            RowLayout {
                spacing: 10

                Rectangle {
                    height: 20; radius: 5; width: typeLabel.implicitWidth + 12
                    color: Theme.tag_preset_bg
                    Text {
                        id: typeLabel; anchors.centerIn: parent
                        text: root.itemType; color: Theme.tag_preset_fg
                        font.pixelSize: 14; font.weight: Font.Bold; font.family: "JetBrains Mono"
                    }
                }

                Text {
                    visible: root.callCount > 0
                    text: root.callCount + " 次"; color: root.statColor
                    font.pixelSize: 14; font.family: "JetBrains Mono"
                }

                Rectangle {
                    visible: root.isOwnAsset
                    height: 20; radius: 5; width: ownBadge.implicitWidth + 12
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                    Text {
                        id: ownBadge; anchors.centerIn: parent
                        text: "我的资产"; color: Theme.accent
                        font.pixelSize: 13; font.weight: Font.Bold
                        font.family: "Microsoft YaHei UI"
                    }
                }
            }
        }

        // ── 价格（仅订阅）──
        ColumnLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: 2
            Text {
                visible: root.subPrice > 0
                text: "¥" + root.subPrice.toFixed(0) + " / " + root.subDuration + "天"
                color: root.titleColor; font.pixelSize: 20; font.weight: Font.Bold
                font.family: "JetBrains Mono"
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
