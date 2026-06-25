import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "../../baseComponents"
import "../../toast"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 20

    signal logoutClicked()
    signal linkAccountsClicked()

    // ── 头像（仅 OAuth 登录有图，密码登录隐藏）──
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Api.avatarUrl ? 80 : 0
        Layout.preferredHeight: Api.avatarUrl ? 80 : 0
        radius: 40; color: "#1f6feb"
        clip: true
        visible: Api.avatarUrl !== ""

        Image {
            anchors.fill: parent
            source: Api.avatarUrl || ""
            fillMode: Image.PreserveAspectCrop
            onStatusChanged: if (status === Image.Error) parent.visible = false
        }
        Text {
            anchors.centerIn: parent
            text: Api.username ? Api.username.charAt(0).toUpperCase() : "U"
            color: "#fff"; font.pixelSize: 36; font.weight: Font.Bold
            font.family: "JetBrains Mono"
            visible: !parent.parent.visible || parent.parent.width < 1
        }
    }

    // ── 用户信息卡片 ──
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: infoColumn.implicitHeight + 32
        color: "#161b22"; radius: 12
        border.color: "#21262d"; border.width: 1

        ColumnLayout {
            id: infoColumn
            anchors.left: parent.left; anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20
            spacing: 14

            InfoRow { label: "用户名"; value: Api.username || "---" }
            InfoRow { label: "邮箱";   value: Api.email    || "---" }
            InfoRow { label: "状态";   value: "已登录"; valueColor: "#3fb950" }
        }
    }

    // ── 关联第三方账号 ──
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "关联第三方账号 ›"
        color: "#58a6ff"; font.pixelSize: 16
        font.family: "Microsoft YaHei UI"
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: root.linkAccountsClicked()
        }
    }

    // ── 退出登录 ──
    SuretyBtn {
        Layout.fillWidth: true
        Layout.topMargin: 8
        Layout.preferredHeight: 48
        text: "退出登录"
        variant: "danger"
        font.pixelSize: 17; font.weight: Font.Bold
        onClicked: root.logoutClicked()
    }

    component InfoRow: RowLayout {
        property string label: ""
        property string value: ""
        property color valueColor: "#c9d1d9"
        Layout.fillWidth: true; spacing: 12
        Text { Layout.preferredWidth: 80; text: label; color: "#8b949e"; font.pixelSize: 18; font.family: "Microsoft YaHei UI" }
        Text { Layout.fillWidth: true; text: value; color: valueColor; font.pixelSize: 18; font.weight: Font.DemiBold; font.family: "Microsoft YaHei UI"; elide: Text.ElideRight }
    }
}
