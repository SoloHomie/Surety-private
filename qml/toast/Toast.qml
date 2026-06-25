import QtQuick
import QtQuick.Controls

// 全局 Toast 通知 — 从顶部滑入，3秒自动消失
// 用法: toast.show("资产保存成功", "success")
Rectangle {
    id: root
    width: toastText.implicitWidth + 48
    height: 44
    radius: 10
    color: _bgColor
    border.width: 1
    border.color: _borderColor

    // 初始隐藏
    opacity: 0
    y: -60
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.top: parent ? parent.top : undefined
    anchors.topMargin: 24
    z: 9999

    // ── 公开属性 ──
    property string toastType: "info"    // info | success | warning | error

    readonly property color _bgColor: {
        switch (toastType) {
            case "success": return "#0d3320"
            case "warning": return "#332210"
            case "error":   return "#330d10"
            default:        return "#161b22"
        }
    }
    readonly property color _borderColor: {
        switch (toastType) {
            case "success": return "#238636"
            case "warning": return "#d29922"
            case "error":   return "#f85149"
            default:        return "#30363d"
        }
    }
    readonly property color _iconColor: {
        switch (toastType) {
            case "success": return "#3fb950"
            case "warning": return "#d29922"
            case "error":   return "#f85149"
            default:        return "#58a6ff"
        }
    }
    readonly property string _icon: {
        switch (toastType) {
            case "success": return "✓"
            case "warning": return "!"
            case "error":   return "✕"
            default:        return "i"
        }
    }

    // ── 显示方法 ──
    function show(message, type) {
        if (type) root.toastType = type
        toastText.text = message || ""
        root.opacity = 1
        root.y = 0
        dismissTimer.restart()
    }

    function dismiss() {
        root.opacity = 0
        root.y = -60
    }

    Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on y       { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }

    Timer {
        id: dismissTimer
        interval: 3000
        onTriggered: root.dismiss()
    }

    Row {
        anchors.centerIn: parent
        spacing: 10

        // 图标
        Rectangle {
            width: 20; height: 20
            radius: 10
            color: _iconColor
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: _icon
                color: "#0d1117"
                font.pixelSize: 11
                font.weight: Font.Bold
                font.family: "JetBrains Mono"
            }
        }

        // 消息文本
        Text {
            id: toastText
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            color: "#e6edf3"
            font.pixelSize: 14
            font.weight: Font.Medium
            font.family: "Microsoft YaHei UI"
        }
    }

    // 点击关闭
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.dismiss()
    }
}
