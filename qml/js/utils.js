// Surety 通用工具函数
.pragma library

// 格式化金额
function formatAmount(amount) {
    if (amount >= 0) return "+" + amount + " Surety"
    return amount + " Surety"
}

// 版本比较: a > b → 1, a == b → 0, a < b → -1
function compareVersion(a, b) {
    var al = a.split('.'), bl = b.split('.')
    for (var i = 0; i < Math.max(al.length, bl.length); i++) {
        var av = i < al.length ? parseInt(al[i]) || 0 : 0
        var bv = i < bl.length ? parseInt(bl[i]) || 0 : 0
        if (av !== bv) return av > bv ? 1 : -1
    }
    return 0
}

// 登录检查 → 返回 true 表示已登录，否则弹 toast 返回 false
function checkLogin() {
    if (!Api.isLoggedIn) {
        ToastManager.add(qsTr("登录后即可使用此功能"), "info", qsTr("需要登录"), 3000)
        return false
    }
    return true
}

// 判断是否是预设类型
function isPresetType(type) {
    var presets = ["Skill", "Script", "Tool", "Model", "Workflow", "Prompt"]
    return presets.indexOf(type) >= 0
}

// 类型名 → 目录名: "Skill" → "skills"
function typeToDir(type) {
    var t = type.toLowerCase()
    return t.endsWith('s') ? t : t + 's'
}
