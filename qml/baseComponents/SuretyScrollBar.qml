import QtQuick
import "../themes"
import QtQuick.Controls

//=============================================================================
// SuretyScrollBar — 全局统一滚动条样式（暗色主题）
//=============================================================================
ScrollBar {
    id: root
    policy: ScrollBar.AsNeeded
    hoverEnabled: true

    contentItem: Rectangle {
        implicitWidth: 4
        radius: 2
        color: Theme.text_hint
        opacity: {
            if (!root.active && !root.hovered) return 0
            if (root.hovered) return 0.7
            return 0.45
        }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    background: Rectangle {
        implicitWidth: 4
        color: "transparent"
    }
}
