import QtQuick
import "../../themes"
import QtQuick.Controls

//=============================================================================
// 时间线单项 — 单侧线性布局（卡片 + 详情展开）
// 用于展示最近操作动态：标题、时间、可展开的详细信息
//=============================================================================
Item {
    id: root
    width: itemWidth

    // ---- 外部属性 ------------------------------------------------
    property real   itemWidth:      500
    property bool   showUpperLine:  true
    property bool   showLowerLine:  true

    property string color:          Theme.success
    property string title:          ""
    property string time:           ""
    property string message:        ""
    property bool   expanded:       false

    signal toggleExpanded()

    // ---- 布局常量 ------------------------------------------------
    readonly property real _lineX:      36
    readonly property real _barW:       3
    readonly property real _dotR:       7
    readonly property real _gap:        20
    readonly property real _cardTop:    8
    readonly property real _cardW:      root.itemWidth - _lineX - _gap - 8
    readonly property real _headerH:    64

    // 总高度
    implicitHeight: _cardTop + _headerH + detailBody.height + 12

    // ---- 垂直线段（上半 / 下半）----------------------------------
    Rectangle {
        id: upperLine
        x: root._lineX
        y: 0
        width: root._barW
        height: nodeDot.y
        color: Theme.border_standard
        visible: root.showUpperLine
    }

    Rectangle {
        id: lowerLine
        x: root._lineX
        y: nodeDot.y + nodeDot.height
        width: root._barW
        height: root.implicitHeight - (nodeDot.y + nodeDot.height)
        color: Theme.border_standard
        visible: root.showLowerLine
    }

    // ---- 节点圆点 ------------------------------------------------
    Rectangle {
        id: nodeDot
        x: root._lineX - root._dotR
        y: root._cardTop + root._headerH / 2 - root._dotR
        width: root._dotR * 2
        height: root._dotR * 2
        radius: root._dotR
        color: expanded ? Qt.darker(root.color, 1.4) : root.color
        border.width: 2
        border.color: Theme.bg_page
        z: 2

        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // ---- 水平连线：节点 → 卡片 -----------------------------------
    Rectangle {
        x: nodeDot.x + nodeDot.width
        y: nodeDot.y + nodeDot.height / 2 - 1
        width: unifiedCard.x - x
        height: 2
        color: root.expanded ? root.color : Theme.border_standard

        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // =========================================================================
    //  一体化卡片
    // =========================================================================
    Item {
        id: unifiedCard
        x: root._lineX + root._gap
        y: root._cardTop
        width: root._cardW
        height: root._headerH + detailBody.height

        // ---- 卡片头部 --------------------------------------------
        Rectangle {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root._headerH

            color: (!root.expanded && headerMouse.containsMouse) ? Theme.border_default : Theme.bg_card
            radius: 8

            // 展开时底部圆角变直角，与详情无缝衔接
            bottomLeftRadius:  detailBody.height > 0 ? 0 : 8
            bottomRightRadius: detailBody.height > 0 ? 0 : 8

            border.width: 1
            border.color: root.expanded ? Theme.border_standard : Theme.border_default

            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            Behavior on border.color {
                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            MouseArea {
                id: headerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleExpanded()
            }

            // 内容行
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 44   // 给展开箭头留空间
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                // 左侧色条
                Rectangle {
                    width: 4
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: root.color
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    // 列宽 = 行宽 - 色条 - 间距
                    width: parent.width - 4 - 14

                    // 标题 — 自适应宽度，超长省略
                    Text {
                        width: parent.width
                        text: root.title || "Untitled"
                        color: Theme.text_primary
                        font.pixelSize: 17
                        font.family: "Microsoft YaHei UI"
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // 时间
                    Text {
                        text: root.time || ""
                        color: Theme.text_hint
                        font.pixelSize: 13
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        width: parent.width
                        maximumLineCount: 1
                    }
                }
            }

            // 展开/折叠箭头
            Image {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                width: 16; height: 16
                source: "qrc:/qml/images/arrow-up.svg"
                fillMode: Image.PreserveAspectFit
                rotation: root.expanded ? 180 : 0
                opacity: headerMouse.containsMouse || root.expanded ? 0.7 : 0.35
                Behavior on rotation {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }
        }

        // ---- 展开详情区 -------------------------------------------
        Item {
            id: detailBody
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            height: root.expanded ? detailLoader.implicitHeight : 0
            clip: true

            Behavior on height {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }

            // 使用 ActiveItemDetail 组件
            Loader {
                id: detailLoader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: root.expanded ? 0 : -8

                active: root.expanded || detailBody.height > 0
                sourceComponent: activeItemDetailComp

                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // ---- ActiveItemDetail 组件定义 ───────────────────────────────
    Component {
        id: activeItemDetailComp

        ActiveItemDetail {
            anchors.left: parent.left
            anchors.right: parent.right
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 8
            bottomRightRadius: 8
            border.width: 1
            border.color: Theme.border_standard
            color: Theme.bg_page

            message: root.message
        }
    }
}
