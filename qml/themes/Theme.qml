import QtQuick
pragma Singleton

QtObject {
    // =========================================================================
    //  GitHub Primer Dark Theme
    //  对照 @primer/primitives dark-color-scale 精确色值
    // =========================================================================

    // =====================================================================
    //  1. 背景色 — 对应 Primer canvas 色阶
    // =====================================================================
    property color bg_page:     "#0d1117"   // canvas.default   — 页面底
    property color bg_card:     "#161b22"   // canvas.subtle    — 卡片 / 侧栏
    property color bg_input:    "#010409"   // canvas.inset     — 输入框（比页面更暗）
    property color bg_overlay:  "#161b22"   // canvas.overlay   — 下拉 / 弹窗 / 浮层
    property color bg_disabled: "#21262d"   // control.disabled — 禁用态

    // =====================================================================
    //  2. 文字色 — 对应 Primer fg 色阶
    // =====================================================================
    property color text_primary:     "#e6edf3"   // fg.default     — 正文
    property color text_secondary:   "#8b949e"   // fg.muted       — 辅助说明
    property color text_hint:        "#6e7681"   // fg.subtle      — 极次要 / 水印
    property color text_placeholder: "#484f58"   // 占位符
    property color text_on_emphasis: "#ffffff"   // fg.onEmphasis — 深色按钮上的文字（唯一白色）
    property color text_disabled:    "#484f58"   // 禁用态文字

    // 链接
    property color text_link:       "#58a6ff"   // accent.fg
    property color text_link_hover: "#79c0ff"   // blue.3

    // 功能色文字（图标 / 状态标签前景）
    property color text_success: "#3fb950"   // success.fg
    property color text_warning: "#d29922"   // attention.fg
    property color text_danger:  "#f85149"   // danger.fg

    // =====================================================================
    //  3. 主色 — accent / blue 色阶
    // =====================================================================
    property color primary:        "#1f6feb"   // accent.emphasis  — 主按钮背景
    property color primary_hover:  "#388bfd"   // blue.4           — 悬停
    property color primary_press:  "#1158c7"   // blue.6           — 按下
    property color primary_text:   "#58a6ff"   // accent.fg        — 图标 / 强调文字
    property color primary_bg:     "#0c2d6b"   // accent.muted solid 等效  — 选中行底
    property color primary_border: "#1f6feb"   // accent.emphasis  — 聚焦边框

    // =====================================================================
    //  4. 功能色 — 命名规则：base=emphasis(按钮) / _text=fg(前景) / _bg=muted(浅色底)
    // =====================================================================

    // --- 成功 / 绿色 ---
    property color success:       "#238636"   // success.emphasis
    property color success_text:  "#3fb950"   // success.fg
    property color success_bg:    "#04260f"   // success.muted solid 等效

    // --- 警告 / 黄色 ---
    property color warning:       "#9e6a03"   // attention.emphasis
    property color warning_text:  "#d29922"   // attention.fg
    property color warning_bg:    "#231a03"   // attention.muted solid 等效

    // --- 危险 / 红色 ---
    property color danger:       "#da3633"   // danger.emphasis
    property color danger_text:  "#f85149"   // danger.fg
    property color danger_bg:    "#2d050b"   // danger.muted solid 等效

    // =====================================================================
    //  5. 扩展色 — done(紫) / sponsors(粉)
    // =====================================================================
    property color purple:       "#8957e5"   // done.emphasis
    property color purple_text:  "#a371f7"   // done.fg
    property color purple_bg:    "#1a112b"   // done.muted solid 等效

    property color pink:         "#bf4b8a"   // sponsors.emphasis
    property color pink_text:    "#db61a2"   // sponsors.fg

    // =====================================================================
    //  6. 边框 — 对应 Primer border 色阶
    // =====================================================================
    property color border:         "#30363d"   // border.default
    property color border_light:   "#21262d"   // border.muted
    property color border_heavy:   "#484f58"   // border.emphasis
    property color border_primary: "#1f6feb"   // accent.emphasis
    property color border_danger:  "#f85149"   // danger.fg
    property color border_success: "#238636"   // success.emphasis

    // =====================================================================
    //  7. 交互态背景（列表项 / 菜单项 hover / press / selected）
    // =====================================================================
    property color hover_bg:    "#161b22"   // canvas.subtle
    property color press_bg:    "#21262d"   // border.muted
    property color selected_bg: "#0c2d6b"   // accent.muted solid 等效

    // =====================================================================
    //  8. 输入控件
    // =====================================================================
    property color input_bg:              "#010409"   // canvas.inset
    property color input_border:          "#30363d"   // border.default
    property color input_border_focus:    "#1f6feb"   // accent.emphasis
    property color input_bg_disabled:     "#161b22"   // canvas.subtle
    property color input_border_disabled: "#21262d"   // border.muted

    // =====================================================================
    //  9. 按钮
    // =====================================================================
    // --- 主按钮（蓝底）---
    property color btn_primary_bg:       "#1f6feb"   // accent.emphasis
    property color btn_primary_hover:    "#388bfd"   // blue.4
    property color btn_primary_press:    "#1158c7"   // blue.6
    property color btn_primary_text:     "#ffffff"   // fg.onEmphasis
    property color btn_primary_disabled: "#11447a"   // accent.emphasis 低透明度等效

    // --- 默认按钮（灰底）---
    property color btn_default_bg:       "#30363d"   // control.default.bg
    property color btn_default_hover:    "#444c56"   // control.default.hoverBg
    property color btn_default_press:    "#21262d"   // control.default.activeBg
    property color btn_default_border:   "#30363d"   // border.default
    property color btn_default_text:     "#e6edf3"   // fg.default

    // --- 危险按钮（红底）---
    property color btn_danger_bg:        "#da3633"   // danger.emphasis
    property color btn_danger_hover:     "#f85149"   // danger.fg
    property color btn_danger_press:     "#b62324"   // red.6
    property color btn_danger_text:      "#ffffff"   // fg.onEmphasis

    // --- 幽灵按钮（仅边框）---
    property color btn_outline_hover_bg: "#30363d"   // border.default

    // =====================================================================
    //  10. 代码高亮（GitHub 暗色语法主题）
    // =====================================================================
    property color code_bg:       "#161b22"
    property color code_text:     "#e6edf3"
    property color code_keyword:  "#ff7b72"   // if / return / class — red
    property color code_string:   "#a5d6ff"   // "hello" — blue
    property color code_comment:  "#8b949e"   // // 注释 — gray
    property color code_number:   "#a5d6ff"   // 42 — blue
    property color code_function: "#d2a8ff"   // foo() — purple
    property color code_type:     "#ffa657"   // int / string — orange
    property color code_variable: "#ffa657"   // varName — orange
    property color code_constant: "#79c0ff"   // CONST — light blue

    // =====================================================================
    //  11. Diff 文件对比
    // =====================================================================
    property color diff_add_bg:      "#04260f"   // success.muted solid 等效
    property color diff_add_text:    "#3fb950"   // success.fg
    property color diff_add_border:  "#1a512b"   // success.muted 边框等效

    property color diff_del_bg:      "#2d050b"   // danger.muted solid 等效
    property color diff_del_text:    "#f85149"   // danger.fg
    property color diff_del_border:  "#5c1d26"   // danger.muted 边框等效

    // =====================================================================
    //  12. 徽章 / 计数器
    // =====================================================================
    property color badge_bg:     "#1c2128"   // primer badge bg (approx)
    property color badge_text:   "#8b949e"   // fg.muted
    property color counter_bg:   "#30363d"   // border.default
    property color counter_text: "#8b949e"   // fg.muted

    // =====================================================================
    //  13. Toast / 通知
    // =====================================================================
    property color toast_bg:           "#161b22"   // canvas.subtle
    property color toast_border:       "#30363d"   // border.default
    property color toast_icon_info:    "#58a6ff"   // accent.fg
    property color toast_icon_success: "#3fb950"   // success.fg
    property color toast_icon_warning: "#d29922"   // attention.fg
    property color toast_icon_danger:  "#f85149"   // danger.fg

    // =====================================================================
    //  14. 滚动条
    // =====================================================================
    property color scrollbar_track:       "#0d1117"   // canvas.default
    property color scrollbar_thumb:       "#30363d"   // border.default
    property color scrollbar_thumb_hover: "#484f58"   // border.emphasis

    // =====================================================================
    //  15. 蒙层 / 阴影
    // =====================================================================
    property color overlay_bg:    "#0d1117"
    property color shadow_color:  "#000000"
    property real  shadow_opacity: 0.5

    // =========================================================================
    //  旧版别名（兼容原有代码）── Qt 6 中 alias 对 singleton 有时不兼容，改用绑定
    // =========================================================================
    property color bg_float:      bg_overlay
    property color divider:       border_light
    property color text_tip:      text_hint
    property color text_white:    text_on_emphasis
    property color info:          primary_text
    property color border_normal: border
    property color border_focus:  border_primary
    property color border_error:  border_danger
    property color mask:          shadow_color
    property real  mask_opacity:  shadow_opacity
}
