pragma Singleton
import QtQuick
import "../themes"

// ═══════════════════════════════════════════════════════════
//  ToastManager — 全局 Toast 单例桥接
//  任意 .qml 文件 import "../toast" 后即可调用:
//    ToastManager.add("消息", "success")
//    ToastManager.add("消息", "warning", "标题", 5000)
// ═══════════════════════════════════════════════════════════
QtObject {
    property var target: null

    function add(message, type, title, duration) {
        if (target) {
            target.add(message, type, title, duration)
        }
    }
}
