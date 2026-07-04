import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: assetDelegate

    // 宽度：外部显式传入，方便后期修改
    property int delegateWidth: 360
    width:  delegateWidth
    height: 64
    radius: 8

    // ── 数据属性（由外层 delegate 绑定传入）─────────
    property int    delegateIndex:  -1
    property string delegateName:   ""
    property string delegateType:   ""
    property color  delegateColor:  Theme.text_bright
    property string delegateVersion: ""
    property bool   delegateSelected: false
    property bool   hasSubscription: false
    property bool   showDelete: true

    signal clicked()
    signal deleteRequested(int index)

    // ── 外观 ────────────────────────────────────────
    color: {
        if (delegateSelected) return Theme.selected_bg
        if (hoverArea.containsMouse) return Theme.bg_page
        return "transparent"
    }
    border.color: delegateSelected ? Theme.accent : "transparent"
    border.width: delegateSelected ? 1 : 0

    Behavior on color       { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

    // ── 交互 ────────────────────────────────────────
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: assetDelegate.clicked()
    }

    // ── 内容 ────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        // 删除按钮 — 委托 hover 时滑出
        Item {
            id: delBtn
            Layout.preferredWidth: showDelete && (hoverArea.containsMouse || delMouse.containsMouse) ? 30 : 0
            Layout.preferredHeight: parent.height
            Layout.rightMargin: 8
            Layout.alignment: Qt.AlignVCenter
            clip: true
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            Image {
                anchors.centerIn: parent
                source: "qrc:/qml/images/delete.svg"
                width: 16; height: 16
                opacity: delMouse.containsMouse ? 1.0 : 0.4
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            MouseArea {
                id: delMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: assetDelegate.deleteRequested(delegateIndex)
            }
        }

        

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            // 名称 + 订阅标识
            Row {
                spacing: 6
                width: parent.width

                Text {
                    width: parent.width - (hasSubscription ? subBadge.width + 6 : 0)
                    text: delegateName
                    color: Theme.text_primary
                    font.pixelSize: 18; font.weight: Font.DemiBold
                    font.family: "Microsoft YaHei UI"
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: subBadge
                    visible: hasSubscription
                    height: 18
                    width: 28
                    radius: 4
                    color: Theme.accent
                    Text {
                        anchors.centerIn: parent
                        text: "SUB"
                        color: Theme.text_bright
                        font.pixelSize: 10; font.weight: Font.Bold
                        font.family: "JetBrains Mono"
                    }
                }
            }

            // 类型 + 版本
            Row {
                spacing: 8

                Rectangle {
                    height: 18
                    width: typeText.implicitWidth + 10
                    radius: 4
                    color: Theme.tag_preset_bg
                    Text {
                        id: typeText
                        anchors.centerIn: parent
                        text: delegateType
                        color: Theme.tag_preset_fg
                        font.pixelSize: 14; font.weight: Font.Bold
                        font.family: "JetBrains Mono"
                    }
                }

                Text {
                    text: "v" + delegateVersion
                    color: Theme.text_hint
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
