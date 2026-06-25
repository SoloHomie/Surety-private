import QtQuick
import QtQuick.Controls

// 通用搜索栏 — pill-shaped, GitHub Primer Dark 风格
// 用法: SearchBar { searchText: page.searchText; onSearchTextChanged: page.searchText = text }
Rectangle {
    id: root
    height: 56
    width:1000
    radius: 28
    border.width: 1

    // ── 公开属性 ──
    property alias  text:            searchInput.text
    property alias  placeholder:     placeholderText.text
    readonly property alias hasFocus: searchInput.activeFocus
    property string shortcutKey:     "Ctrl+K"

    signal searchTextChanged(string text)
    signal shortcutActivated()

    // 取消输入焦点
    function clearFocus() {
        searchInput.focus = false
    }

    readonly property bool _hovered: barHoverArea.containsMouse && !searchInput.activeFocus
    readonly property bool _focused: searchInput.activeFocus

    color: _focused ? "#0d1117" : (_hovered ? "#060d15" : "#010409")
    border.color: _focused ? "#1f6feb" : (_hovered ? "#30363d" : "#21262d")

    Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    Behavior on border.color {
        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    // 外发光
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: parent.radius + 2
        color: "transparent"
        border.width: 2
        border.color: "#1f6feb"
        opacity: root._focused ? 0.25 : 0.0
        visible: opacity > 0.0
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
    }

    // 搜索图标
    Image {
        id: searchIcon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 18
        width: 20; height: 20
        source: "qrc:/qml/images/搜索.svg"
        sourceSize.width: 20; sourceSize.height: 20
        opacity: root._focused  ? 1.0 : root._hovered ? 0.75 : 0.5
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // 输入框
    TextInput {
        id: searchInput
        anchors.left: searchIcon.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        height: parent.height
        color: "#e6edf3"
        font.pixelSize: 18
        font.family: "JetBrains Mono"
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        selectByMouse: true
        activeFocusOnPress: true
        selectionColor: "#1f6feb"
        selectedTextColor: "#ffffff"

        onTextChanged: root.searchTextChanged(text)

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                text = ""
                focus = false
            }
        }
    }

    // 占位文本
    Text {
        id: placeholderText
        anchors.fill: searchInput
        verticalAlignment: Text.AlignVCenter
        text: "Search assets, knowledge packs..."
        color: root._focused ? "#6e7681" : "#484f58"
        font.pixelSize: 18
        font.family: "JetBrains Mono"
        elide: Text.ElideRight
        visible: !searchInput.activeFocus && searchInput.text === ""
        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // 点击聚焦
    MouseArea {
        id: barHoverArea
        anchors.fill: parent
        z: 0
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        onClicked: {
            searchInput.focus = true
            searchInput.cursorPosition = searchInput.text.length
        }
    }

    // 全局快捷键
    Shortcut {
        sequence: root.shortcutKey
        onActivated: {
            searchInput.focus = true
            searchInput.cursorPosition = searchInput.text.length
            root.shortcutActivated()
        }
    }
}
