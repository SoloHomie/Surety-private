import QtQuick
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
    property color  delegateColor:  "#ffffff"
    property string delegateVersion: ""
    property bool   delegateSelected: false
    property bool   hasSubscription: false

    signal clicked()

    // ── 外观 ────────────────────────────────────────
    color: {
        if (delegateSelected) return "#1a2332"
        if (hoverArea.containsMouse) return "#0d1117"
        return "transparent"
    }
    border.color: delegateSelected ? "#1f6feb" : "transparent"
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
        spacing: 12

        // 头像
        Rectangle {
            Layout.preferredWidth: 36; Layout.preferredHeight: 36
            radius: 8
            color: Qt.rgba(delegateColor.r, delegateColor.g, delegateColor.b, 0.18)

            Text {
                anchors.centerIn: parent
                text: delegateName.charAt(0)
                color: delegateColor
                font.pixelSize: 20; font.weight: Font.Bold
                font.family: "JetBrains Mono"
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
                    color: "#e6edf3"
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
                    color: "#1f6feb"
                    Text {
                        anchors.centerIn: parent
                        text: "SUB"
                        color: "#fff"
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
                    color: Qt.rgba(delegateColor.r, delegateColor.g, delegateColor.b, 0.15)
                    Text {
                        id: typeText
                        anchors.centerIn: parent
                        text: delegateType
                        color: delegateColor
                        font.pixelSize: 14; font.weight: Font.Bold
                        font.family: "JetBrains Mono"
                    }
                }

                Text {
                    text: "v" + delegateVersion
                    color: "#6e7681"
                    font.pixelSize: 14
                    font.family: "JetBrains Mono"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
