import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

//=============================================================================
// MyBtn — GitHub Primer Dark 按钮
// variant: "primary" | "default" | "danger" | "outline"
//=============================================================================
Rectangle {
    id: root
    width: 80
    height: 32
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
    readonly property color _bg: !enabled ? "#21262d" :
        _pri && mouseArea.pressed            ? "#1158c7" :
        _pri && mouseArea.containsMouse      ? "#388bfd" :
        _pri                                 ? "#1f6feb" :
        _dng && mouseArea.pressed            ? "#b62324" :
        _dng && mouseArea.containsMouse      ? "#f85149" :
        _dng                                 ? "#da3633" :
        _out && mouseArea.pressed            ? "#30363d" :
        _out && mouseArea.containsMouse      ? "#21262d" :
        _out                                 ? "transparent" :
        mouseArea.pressed                    ? "#30363d" :
        mouseArea.containsMouse              ? "#444c56" : "#30363d"

    // ---- 边框 ----
    readonly property color _border: !enabled ? "#21262d" :
        _out ? "#30363d" : "transparent"

    // ---- 文字色 ----
    readonly property color _text: !enabled ? "#484f58" :
        _pri || _dng ? "#ffffff" : "#e6edf3"

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
