import QtQuick

Rectangle {
    id: root

    property alias  text:            inputField.text
    property alias  readOnly:        inputField.readOnly
    property alias  font:            inputField.font
    property alias  echoMode:        inputField.echoMode
    property alias  validator:       inputField.validator
    property alias  inputMask:       inputField.inputMask
    property string label:           ""
    property string placeholder:     ""
    property bool   isError:         false
    property alias  hovered:         hoverArea.containsMouse

    signal accepted()

    implicitWidth: 240
    implicitHeight: labelText.visible ? labelText.implicitHeight + 6 + 44 : 44
    color: "transparent"

    // ---- 标签 ----
    Text {
        id: labelText
        anchors.left: parent.left
        anchors.top: parent.top
        visible: root.label !== ""
        text: root.label
        color: "#8b949e"
        font.pixelSize: 16
        font.weight: Font.Bold
        font.family: "JetBrains Mono"
    }

    // ---- 输入框容器 ----
    Rectangle {
        id: inputBox
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: labelText.visible ? labelText.bottom : parent.top
        anchors.topMargin: labelText.visible ? 6 : 0
        height: 44
        radius: 8
        color: inputField.readOnly ? "#0a0e13" : "#0d1117"
        border.width: 1
        border.color: {
            if (root.isError)               return "#f85149"
            if (inputField.activeFocus)     return "#1f6feb"
            if (hoverArea.containsMouse)    return "#30363d"
            return "#21262d"
        }
        Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // focus / error glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.width: 2
            border.color: root.isError ? "#f85149" : "#1f6feb"
            opacity: (inputField.activeFocus || root.isError) ? 0.22 : 0.0
            visible: opacity > 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        }

        // hover 层 — 声明在 TextInput 之前, 事件后到达, 只负责 hover
        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        // placeholder
        Text {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            verticalAlignment: Text.AlignVCenter
            text: root.placeholder
            color: "#484f58"
            font: inputField.font
            elide: Text.ElideRight
            visible: inputField.text === "" && !inputField.activeFocus && !inputField.readOnly
        }

        // 原生 TextInput — 声明在后, 事件先到达 (原生行为完整保留)
        TextInput {
            id: inputField
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            color: readOnly ? "#6e7681" : "#e6edf3"
            font.pixelSize: 18
            font.family: "Microsoft YaHei UI"
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            selectByMouse: true
            activeFocusOnPress: !readOnly
            selectionColor: "#1f6feb"
            selectedTextColor: "#ffffff"
            cursorVisible: activeFocus

            onAccepted: root.accepted()

            // cursor shape only — 不拦截事件
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: inputField.readOnly ? Qt.ArrowCursor : Qt.IBeamCursor
            }
        }
    }

    // ---- error ----
    Text {
        anchors.left: parent.left
        anchors.top: inputBox.bottom
        anchors.topMargin: 4
        visible: root.isError
        text: "Invalid input"
        color: "#f85149"
        font.pixelSize: 14
        font.family: "JetBrains Mono"
    }
}
