import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

Rectangle {
    id: root
    color: "#010409"
    radius: 12
    border.color: "#21262d"
    border.width: 1
    clip: true

    // ── 公开接口 ──
    property alias  nameText:    nameField.text
    property alias  versionText: versionField.text
    property alias  descText:    descField.text
    property alias  typeIndex:     typeSelector.selectedIndex
    property alias  oncePrice:     oncePriceField.text
    property alias  subPrice:      subPriceField.text
    property alias  subDuration:   subDurationField.text
    property string titleText:     "---"
    property bool   isReadOnly:    false    // 订阅资产禁止编辑

    readonly property string selectedType: {
        if (typeSelector.selectedIndex < 0 || typeSelector.selectedIndex >= typeModel.count) return ""
        return typeModel.get(typeSelector.selectedIndex).label
    }
    readonly property string selectedTypeCode: {
        if (typeSelector.selectedIndex < 0 || typeSelector.selectedIndex >= typeModel.count) return "#1f6feb"
        return typeModel.get(typeSelector.selectedIndex).code
    }

    signal saveClicked()

    // ═══════════════════════════════════════════════
    //  颜色工具
    // ═══════════════════════════════════════════════
    readonly property var _palette: ["#C89B3C", "#34D399", "#58A6FF", "#A371F7", "#F59E0B", "#F85149", "#00BCD4", "#FF7043"]

    function _colorFor(name) {
        var hash = 0
        for (var i = 0; i < name.length; i++)
            hash = name.charCodeAt(i) + ((hash << 5) - hash)
        return _palette[Math.abs(hash) % _palette.length]
    }

    // ═══════════════════════════════════════════════
    //  自定义类型
    // ═══════════════════════════════════════════════
    function addCustomType(name) {
        name = name.trim()
        if (name === "") return
        // 已存在则直接选中
        for (var i = 0; i < typeModel.count; i++) {
            if (typeModel.get(i).label === name) {
                typeSelector.selectedIndex = i
                customTypeRow.visible = false
                customTypeInput.text = ""
                return
            }
        }
        // 新类型：追加到模型并选中
        typeModel.append({ label: name, code: _colorFor(name) })
        typeSelector.selectedIndex = typeModel.count - 1
        customTypeRow.visible = false
        customTypeInput.text = ""
    }

    // ── 便捷方法：加载一条资产数据 ──
    function load(item) {
        if (!item) {
            root.titleText = "---"
            nameField.text    = ""
            versionField.text = ""
            descField.text    = ""
            typeSelector.selectedIndex = 0
            return
        }

        // 匹配类型：找不到则自动添加为自定义类型
        var foundIdx = -1
        for (var i = 0; i < typeModel.count; i++) {
            if (typeModel.get(i).label === (item.type || "")) {
                foundIdx = i
                break
            }
        }
        if (foundIdx < 0 && item.type) {
            typeModel.append({ label: item.type, code: item.code || _colorFor(item.type) })
            foundIdx = typeModel.count - 1
        }
        typeSelector.selectedIndex = foundIdx >= 0 ? foundIdx : 0

        root.isReadOnly   = item.hasSubscription === true
        root.titleText    = item.name || "---"
        nameField.text    = item.name    || ""
        versionField.text = item.version || ""
        descField.text    = item.desc   || ""
        oncePriceField.text = ""
        subPriceField.text  = ""
        subDurationField.text = ""
    }

    // =========================================================================
    //  可滚动内容区
    // =========================================================================
    Flickable {
        id: detailFlick
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: actionBar.top
        focusPolicy: Qt.NoFocus
        anchors.margins: 28
        anchors.bottomMargin: 12
        contentHeight: detailColumn.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ScrollBar.vertical: SuretyScrollBar { }

        ColumnLayout {
            id: detailColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 20

            // ── 标题 ──
            Text {
                color: "#e6edf3"
                text: root.titleText
                font.pixelSize: 28
                font.weight: Font.Bold
                font.family: "Microsoft YaHei UI"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#21262d"
            }

            SuretyTextField {
                id: nameField
                Layout.fillWidth: true
                placeholder: "输入资产名称"
                enabled: !root.isReadOnly
            }

            // ── 资产类型选择 ──
            SuretyTagSelector {
                id: typeSelector
                Layout.leftMargin: 0
                Layout.fillWidth: true
                visible: !root.isReadOnly
                enabled: !root.isReadOnly
                model: ListModel {
                    id: typeModel
                    ListElement { label: "知识包"; code: "#C89B3C" }
                    ListElement { label: "脚本";   code: "#34D399" }
                    ListElement { label: "工具";   code: "#A371F7" }
                    ListElement { label: "模型";   code: "#58A6FF" }
                    ListElement { label: "工作流"; code: "#F59E0B" }
                }
            }

            // 只读模式：显示单一类型标签
            Rectangle {
                visible: root.isReadOnly
                Layout.preferredHeight: 38
                Layout.preferredWidth: readonlyTypeText.implicitWidth + 28
                radius: 8
                color: Qt.rgba(
                    typeSelector.selectedIndex >= 0 && typeSelector.selectedIndex < typeModel.count
                        ? typeModel.get(typeSelector.selectedIndex).code : "#1f6feb",
                    0.15)
                border.width: 1
                border.color: Qt.rgba(
                    typeSelector.selectedIndex >= 0 && typeSelector.selectedIndex < typeModel.count
                        ? typeModel.get(typeSelector.selectedIndex).code : "#1f6feb",
                    0.4)

                Text {
                    id: readonlyTypeText
                    anchors.centerIn: parent
                    text: root.selectedType || "类型"
                    color: typeSelector.selectedIndex >= 0 && typeSelector.selectedIndex < typeModel.count
                        ? typeModel.get(typeSelector.selectedIndex).code : "#1f6feb"
                    font.pixelSize: 15; font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                }
            }

            // ── 自定义类型输入 ──
            RowLayout {
                id: customTypeRow
                visible: false
                Layout.fillWidth: true
                spacing: 8

                SuretyTextField {
                    id: customTypeInput
                    Layout.fillWidth: true
                    placeholder: "输入自定义类型名称（回车确认）"
                    enabled: !root.isReadOnly
                    onAccepted: root.addCustomType(customTypeInput.text)
                }
                SuretyBtn {
                    text: "+"; width: 40; height: 42; variant: "primary"
                    enabled: !root.isReadOnly
                    font.pixelSize: 20; font.weight: Font.Bold
                    onClicked: root.addCustomType(customTypeInput.text)
                }
            }

            SuretyBtn {
                visible: !customTypeRow.visible && !root.isReadOnly
                enabled: !root.isReadOnly
                text: "+ 自定义类型"
                width: 130
                height: 32
                variant: "outline"
                font.pixelSize: 14
                onClicked: customTypeRow.visible = true
            }

            // ── 自定义类型可删除标签 ──
            Flow {
                Layout.fillWidth: true
                spacing: 6
                visible: customRepeater.count > 0

                Repeater {
                    id: customRepeater
                    model: typeModel

                    delegate: Rectangle {
                        visible: index >= 5          // 仅自定义类型（前 5 个为预设）
                        height: 30; radius: 7
                        width: chipLabel.implicitWidth + 36
                        color: "#161b22"
                        border.width: 1
                        border.color: model.code

                        Text {
                            id: chipLabel
                            anchors.left: parent.left; anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.label
                            color: model.code
                            font.pixelSize: 14; font.weight: Font.DemiBold
                            font.family: "Microsoft YaHei UI"
                        }

                        Rectangle {
                            anchors.right: parent.right; anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20; height: 20; radius: 10
                            color: chipCloseMA.containsMouse ? "#30363d" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "×"; color: "#8b949e"
                                font.pixelSize: 16; font.weight: Font.Bold
                            }

                            MouseArea {
                                id: chipCloseMA
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // 如果删除的是当前选中项，重置选中
                                    if (typeSelector.selectedIndex === index)
                                        typeSelector.selectedIndex = 0
                                    else if (typeSelector.selectedIndex > index)
                                        typeSelector.selectedIndex = typeSelector.selectedIndex - 1
                                    typeModel.remove(index)
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                SuretyTextField {
                    id: versionField
                    Layout.fillWidth: true
                    placeholder: "版本号"
                    enabled: !root.isReadOnly
                }
            }

            // ── 定价设置（仅非订阅资产可见）─────────────
            Rectangle {
                visible: !root.isReadOnly
                Layout.fillWidth: true
                height: 1
                color: "#21262d"
            }

            Text {
                visible: !root.isReadOnly
                text: "定价设置"
                color: "#e6edf3"
                font.pixelSize: 16
                font.weight: Font.Bold
                font.family: "Microsoft YaHei UI"
            }

            // 永久买断
            RowLayout {
                visible: !root.isReadOnly
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 28
                    radius: 6
                    color: "#1a2332"
                    Text {
                        anchors.centerIn: parent
                        text: "永久买断"
                        color: "#58A6FF"
                        font.pixelSize: 13; font.weight: Font.Bold
                        font.family: "Microsoft YaHei UI"
                    }
                }

                SuretyTextField {
                    id: oncePriceField
                    Layout.fillWidth: true
                    placeholder: "输入价格（如 299）"
                }

                Text {
                    text: "¥"
                    color: "#8b949e"
                    font.pixelSize: 16
                    font.family: "JetBrains Mono"
                }
            }

            // 订阅
            RowLayout {
                visible: !root.isReadOnly
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 28
                    radius: 6
                    color: "#1a2332"
                    Text {
                        anchors.centerIn: parent
                        text: "订阅"
                        color: "#3fb950"
                        font.pixelSize: 13; font.weight: Font.Bold
                        font.family: "Microsoft YaHei UI"
                    }
                }

                SuretyTextField {
                    id: subPriceField
                    Layout.fillWidth: true
                    placeholder: "输入价格（如 29）"
                }

                Text {
                    text: "¥ /"
                    color: "#8b949e"
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                }

                SuretyTextField {
                    id: subDurationField
                    Layout.preferredWidth: 60
                    placeholder: "天"
                }
            }

            SuretyTextArea {
                id: descField
                Layout.fillWidth: true
                enabled: !root.isReadOnly
                placeholder: "请输入资产相关信息..."
                minHeight: 140
            }

            // 底部留白
            Item { Layout.preferredHeight: 8 }
        }
    }

    // =========================================================================
    //  底部按钮栏
    // =========================================================================
    Rectangle {
        id: actionBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        height: 52
        color: "transparent"

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#21262d"
        }

        SuretyBtn {
            id: saveBtn
            enabled: !root.isReadOnly
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 120; height: 40
            text: "保存资产"
            variant: "primary"
            font: Qt.font({
                family: "Microsoft YaHei UI",
                pixelSize: 18,
                weight: Font.Bold
            })
            onClicked: root.saveClicked()
        }
    }
}
