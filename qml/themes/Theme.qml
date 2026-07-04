import QtQuick
pragma Singleton

QtObject {
    // =========================================================================
    //  Surety Dark Theme · 极暗灰度色阶体系
    //  基色 #010409 | 10 级灰阶 | 每级含 ~1% 蓝调
    // =========================================================================

    // ---- 色阶基元 (Primitive Scale) — HTML 色阶表 ----
    property color neutral0: "#010409"   // L0  画布底
    property color neutral1: "#0d1117"   // L1  表面 / 按钮底
    property color neutral2: "#161b22"   // L2  卡片 / 按下态
    property color neutral3: "#1c2128"   // L3  悬停态
    property color neutral4: "#21262d"   // L4  微弱边框
    property color neutral5: "#30363d"   // L5  标准边框
    property color neutral6: "#484f58"   // L6  强调边框 / 聚焦环
    property color neutral7: "#6e7681"   // L7  水印 / 分割线文字
    property color neutral8: "#8b949e"   // L8  辅助文字 / 图标
    property color neutral9: "#c9d1d9"   // L9  正文

    // ---- 品牌蓝 (Accent Triad) ----
    property color accent:        "#1f6feb"   // 默认
    property color accent_hover:  "#388bfd"   // 悬停
    property color accent_press:  "#1158c7"   // 按下

    // ---- 功能色 (Functional) ----
    property color success:      "#238636"   // 成功底
    property color success_fg:   "#3fb950"   // 成功文字
    property color warning:      "#9e6a03"   // 警告底
    property color warning_fg:   "#d29922"   // 警告文字
    property color danger:       "#da3633"   // 危险底
    property color danger_fg:    "#f85149"   // 危险文字
    property color purple:       "#8957e5"   // 紫色
    property color purple_fg:    "#a371f7"   // 紫色文字

    // ---- 基础色 ----
    property color white: "#ffffff"
    property color black: "#000000"

    // =========================================================================
    //  语义层 (Semantic Tokens)
    // =========================================================================

    // ---- 背景 ----
    property color bg_canvas:   neutral0   // 全局画布
    property color bg_page:     neutral1   // 页面底
    property color bg_card:     neutral2   // 卡片 / 面板
    property color bg_input:    neutral0   // 输入框（凹陷）
    property color bg_disabled: neutral4   // 禁用态

    // ---- 文字 ----
    property color text_primary:   neutral9   // 正文
    property color text_secondary: neutral8   // 辅助说明
    property color text_hint:      neutral7   // 水印 / 占位
    property color text_disabled:  neutral6   // 禁用文字
    property color text_bright:    white      // 深色底反白

    // ---- 边框 ----
    property color border_default:  neutral4   // 微弱边框
    property color border_standard: neutral5   // 标准边框
    property color border_emphasis: neutral6   // 强调 / 聚焦环
    property color border_accent:   accent     // 品牌蓝聚焦

    // ---- 交互态 ----
    property color hover_bg: neutral3   // 悬停背景
    property color press_bg: neutral2   // 按下背景

    // ---- 按钮 ----
    property color btn_primary_bg:     accent
    property color btn_primary_hover:  accent_hover
    property color btn_primary_press:  accent_press
    property color btn_primary_text:   white
    property color btn_default_bg:     neutral1
    property color btn_default_border: neutral4
    property color btn_default_text:   neutral9
    property color btn_hover_bg:       neutral3
    property color btn_press_bg:       neutral2
    property color btn_danger_bg:      danger
    property color btn_danger_hover:   danger_fg
    property color btn_danger_press:   "#b62324"
    property color btn_danger_text:    white

    // ---- 输入控件 ----
    property color input_bg:           neutral0
    property color input_border:       neutral4
    property color input_border_hover: neutral5
    property color input_border_focus: accent
    property color input_text:         neutral9
    property color input_placeholder:  neutral6
    property color input_readonly_bg:  "#0a0e13"

    // ---- 滚动条 ----
    property color scrollbar_track:       neutral1
    property color scrollbar_thumb:       neutral5
    property color scrollbar_thumb_hover: neutral6

    // ---- 蒙层 ----
    property color overlay_bg:   neutral1
    property color shadow_color: black
    property real  shadow_alpha: 0.5

    // ---- 链接 / 轻量强调 ----
    property color accent_text: "#58a6ff"   // 链接、轻量品牌提示

    // ---- 选中态 ----
    property color selected_bg:     "#1a2332"   // 选中行底色
    property color selected_border: accent

    // ---- 资产类型标签 ----
    property color tag_preset_bg: "#1a3a5c"    // 预设类型背景
    property color tag_preset_fg: "#58a6ff"    // 预设类型文字
    property color tag_custom_bg: "#2d1f4e"    // 自定义类型背景
    property color tag_custom_fg: "#a371f7"    // 自定义类型文字
}
