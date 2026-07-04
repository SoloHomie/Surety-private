import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"
import "../../toast"

Rectangle {
    id: root
    color: Theme.bg_input
    radius: 12
    border.color: Theme.border_default
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
    property string saveBtnText:   "保存资产"
    property bool   isReadOnly:    false    // 订阅资产禁止编辑

    readonly property string selectedType: {
        if (typeSelector.selectedIndex < 0 || typeSelector.selectedIndex >= typeModel.count) return ""
        return typeModel.get(typeSelector.selectedIndex).label
    }
    readonly property string selectedTypeCode: {
        if (typeSelector.selectedIndex < 0 || typeSelector.selectedIndex >= typeModel.count) return Theme.accent
        return typeModel.get(typeSelector.selectedIndex).code
    }

    signal saveClicked()

    // 按名称选择类型（找不到则自动添加为自定义类型）
    function selectType(typeName) {
        for (var i = 0; i < typeModel.count; i++) {
            if (typeModel.get(i).label === typeName) { typeSelector.selectedIndex = i; return }
        }
        if (typeName && typeName !== "") {
            typeModel.append({ label: typeName, code: _colorFor(typeName) })
            typeSelector.selectedIndex = typeModel.count - 1
        }
    }

    // ═══════════════════════════════════════════════
    //  颜色工具
    // ═══════════════════════════════════════════════
    function _colorFor(name) { return "#a371f7" }

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
        // 定价由 VaultPage._selectAsset 设置，这里不做清空
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
            anchors.rightMargin: 12
            anchors.top: parent.top
            spacing: 20

            // ── 标题 ──
            Text {
                color: Theme.text_primary
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
                color: Theme.border_default
            }

            SuretyTextField {
                id: nameField
                Layout.fillWidth: true
                placeholder: qsTr("资产名称")
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
                    ListElement { label: "Skill"; code: "#58a6ff" }
                    ListElement { label: "Script"; code: "#58a6ff" }
                    ListElement { label: "Tool"; code: "#58a6ff" }
                    ListElement { label: "Model"; code: "#58a6ff" }
                    ListElement { label: "Workflow"; code: "#58a6ff" }
                }
            }

            // 只读模式：显示单一类型标签
            Rectangle {
                visible: root.isReadOnly
                Layout.preferredHeight: 38
                Layout.preferredWidth: readonlyTypeText.implicitWidth + 28
                radius: 8
                color: Theme.tag_preset_bg
                border.width: 1
                border.color: Theme.accent_text

                Text {
                    id: readonlyTypeText
                    anchors.centerIn: parent
                    text: root.selectedType || "类型"
                    color: Theme.tag_preset_fg
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
                text: qsTr("+ 自定义类型")
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
                        visible: index >= 5
                        height: 30; radius: 7
                        width: chipLabel.implicitWidth + 36
                        color: "#1e1e3f"
                        border.width: 1
                        border.color: "#a371f7"

                        Text {
                            id: chipLabel
                            anchors.left: parent.left; anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.label
                            color: "#a371f7"
                            font.pixelSize: 14; font.weight: Font.DemiBold
                            font.family: "Microsoft YaHei UI"
                        }

                        Rectangle {
                            anchors.right: parent.right; anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20; height: 20; radius: 10
                            color: chipCloseMA.containsMouse ? Theme.border_standard : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "×"; color: Theme.text_secondary
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
                    placeholder: qsTr("版本号")
                    enabled: !root.isReadOnly
                }
            }

            // 隐藏：对齐旧别名，MVP 只用订阅价
            Item { visible: false
                property alias text: oncePriceField.text
                SuretyTextField { id: oncePriceField; text: "" }
            }

            // ── 订阅定价 ──
            Rectangle {
                visible: !root.isReadOnly
                Layout.fillWidth: true; height: 1; color: Theme.border_default
            }
            Text {
                visible: !root.isReadOnly
                text: qsTr("订阅定价")
                color: Theme.text_primary; font.pixelSize: 16; font.weight: Font.Bold
                font.family: "Microsoft YaHei UI"
            }
            RowLayout {
                visible: !root.isReadOnly
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 28
                    Layout.fillHeight: true
                    radius: 6
                    color: Theme.selected_bg
                    Text {
                        anchors.centerIn: parent
                        text: "订阅"
                        color: Theme.success_fg
                        font.pixelSize: 15; font.weight: Font.Bold
                        font.family: "Microsoft YaHei UI"
                    }
                }

                SuretyTextField {
                    id: subPriceField
                    Layout.fillWidth: true
                    placeholder: qsTr("输入价格")
                }

                Text {
                    text: "¥ /"
                    color: Theme.text_secondary
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
                placeholder: qsTr("请输入资产相关信息...")
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
            color: Theme.border_default
        }

        SuretyBtn {
            id: saveBtn
            enabled: !root.isReadOnly
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 120; height: 40
            text: qsTr(root.saveBtnText)
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
