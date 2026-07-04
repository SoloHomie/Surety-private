import QtQuick
import "../themes"

//=============================================================================
// SuretyTooltip — 暗色主题浮层提示
//
// 外部接口 (均可从外部覆盖):
//   text          — 提示文字 (alias → label.text，保持绑定)
//   shown         — 显示/隐藏，带动画
//   width         — 显式宽度；不设则自适应 (上限 maxWidth)。直接在外部写: width: 200
//   maxWidth      — 自适应时的最大宽度 (默认 260)
//   placement     — Tooltip._top / Tooltip._bottom (默认 Top，箭头在下方)
//   arrowVisible  — 是否显示三角箭头 (默认 true)
//   labelFont     — 字体属性 (alias → label.font)
//   innerSpacing  — 内容水平内边距 (默认 12)
//
// 用法:
//   Tooltip {
//       text: "批量执行工作流"
//       shown: hovered
//       width: 180            // 可选，不设则自适应
//       x: (parent.width - width) / 2
//       y: -height - 6
//   }
//=============================================================================
Rectangle {
    id: root

    // ---- 公开属性 ------------------------------------------------
    property alias  text:         label.text
    property bool   shown:        true              // 设计预览用，实例中会覆盖为 false
    property int    maxWidth:     260
    property int    placement:    Tooltip._top
    property bool   arrowVisible: true
    property alias  labelFont:    label.font
    property real   innerSpacing: 12

    // 枚举值
    readonly property int _top: 0
    readonly property int _bottom: 1

    // ---- 尺寸 ----------------------------------------------------
    // implicitWidth 根据内容自动计算；外部设置 width 即可覆盖
    implicitWidth: Math.min(label.implicitWidth + innerSpacing * 2, maxWidth)
    width: implicitWidth
    height: label.implicitHeight + 16 + (arrowVisible ? 5 : 0)

    // ---- 视觉 ----------------------------------------------------
    color: Theme.border_default
    radius: 6
    border.width: 1
    border.color: Theme.border_standard

    // 弱阴影 (外发光替代，避免复杂多层)
    layer.enabled: true
    layer.effect: null  // 占位，后续可加 DropShadow

    // ---- 入场/退场 ------------------------------------------------
    // 微缩放 + 淡入，避免 transform.y 在不同 Qt 版本的兼容问题
    scale: shown ? 1.0 : 0.96

    opacity: shown ? 1.0 : 0.0
    visible: opacity > 0.0 && label.text !== ""

    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
        NumberAnimation { duration: 180; easing.type: Easing.OutBack }
    }

    // ---- 文字 ----------------------------------------------------
    Text {
        id: label
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.arrowVisible
            ? (root.placement === Tooltip._top ? -2 : 2)
            : 0
        text: "Tooltip"             // 设计预览默认值，外部通过 alias 覆盖
        color: Theme.text_primary
        font.pixelSize: 14
        font.family: "Microsoft YaHei UI"
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        maximumLineCount: 3
        width: root.width - root.innerSpacing * 2
        horizontalAlignment: Text.AlignHCenter
    }

    // ---- 三角箭头 ------------------------------------------------
    Canvas {
        id: arrowCanvas
        visible: root.arrowVisible
        width: 10
        height: 5

        anchors.horizontalCenter: root.horizontalCenter
        anchors.top:    root.placement === Tooltip._top    ? root.bottom : undefined
        anchors.bottom: root.placement === Tooltip._bottom ? root.top    : undefined

        onPaint: {
            let ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = Theme.border_default
            ctx.beginPath()
            if (root.placement === Tooltip._top) {
                ctx.moveTo(0, 0)
                ctx.lineTo(width / 2, height)
                ctx.lineTo(width, 0)
            } else {
                ctx.moveTo(0, height)
                ctx.lineTo(width / 2, 0)
                ctx.lineTo(width, height)
            }
            ctx.closePath()
            ctx.fill()

            // 左侧边框
            ctx.strokeStyle = Theme.border_standard
            ctx.lineWidth = 1
            ctx.beginPath()
            if (root.placement === Tooltip._top) {
                ctx.moveTo(0, 0)
                ctx.lineTo(width / 2, height)
            } else {
                ctx.moveTo(0, height)
                ctx.lineTo(width / 2, 0)
            }
            ctx.stroke()
        }
    }

    // 尺寸/位置变化时重绘箭头
    onXChanged:        if (arrowVisible) arrowCanvas.requestPaint()
    onYChanged:        if (arrowVisible) arrowCanvas.requestPaint()
    onWidthChanged:    if (arrowVisible) arrowCanvas.requestPaint()
}
