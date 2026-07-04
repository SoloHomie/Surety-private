import QtQuick
import "../themes"
import QtQuick.Controls
import QtQuick.Layouts

//=============================================================================
// MyBtn — GitHub Primer Dark 按钮
// variant: "primary" | "default" | "danger" | "outline"
//=============================================================================
Rectangle {
    id: root
    implicitWidth: Math.max(80, btnText.implicitWidth + 28)
    implicitHeight: 32
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    width: implicitWidth
    height: implicitHeight
    radius: 6

    property string text:       "Button"
    property string variant:    "default"
    property bool   enabled:    true
    property string iconSource: ""

    // ---- 字体属性 (完全暴露) ----
    property font   font: Qt.font({
        family:     "JetBrains Mono",
        pixelSize:  16,
        weight:     Font.Medium,
        italic:     false,
        underline:  false
    })

    signal clicked()

    // ---- 变体标记 ----
    readonly property bool _pri: variant === "primary"
    readonly property bool _dng: variant === "danger"
    readonly property bool _out: variant === "outline"

    // ---- 背景色 ----
    readonly property color _bg: !enabled ? Theme.border_default :
        _pri && mouseArea.pressed            ? Theme.accent_press :
        _pri && mouseArea.containsMouse      ? Theme.accent_hover :
        _pri                                 ? Theme.accent :
        _dng && mouseArea.pressed            ? Theme.btn_danger_press :
        _dng && mouseArea.containsMouse      ? Theme.danger_fg :
        _dng                                 ? Theme.danger :
        _out && mouseArea.pressed            ? Theme.border_standard :
        _out && mouseArea.containsMouse      ? Theme.border_default :
        _out                                 ? "transparent" :
        mouseArea.pressed                    ? Theme.border_standard :
        mouseArea.containsMouse              ? Theme.border_emphasis : Theme.border_standard

    // ---- 边框 ----
    readonly property color _border: !enabled ? Theme.border_default :
        _out ? Theme.border_standard : "transparent"

    // ---- 文字色 ----
    readonly property color _text: !enabled ? Theme.text_disabled :
        _pri || _dng ? Theme.text_bright : Theme.text_primary

    color: _bg
    border.width: _out ? 1 : 0
    border.color: _border

    Behavior on color        { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

    RowLayout {
        anchors.centerIn: parent
        spacing: root.iconSource !== "" ? 8 : 0

        Image {
            id: btnIcon
            visible: root.iconSource !== ""
            Layout.preferredWidth: visible ? 20 : 0
            Layout.preferredHeight: visible ? 20 : 0
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            id: btnText
            text: root.text
            color: root._text
            font: root.font
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
