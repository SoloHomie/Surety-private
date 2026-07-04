import QtQuick
import "../../themes"
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
        radius: 40; color: Theme.accent
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
            color: Theme.text_bright; font.pixelSize: 36; font.weight: Font.Bold
            font.family: "JetBrains Mono"
            visible: !parent.parent.visible || parent.parent.width < 1
        }
    }

    // ── 用户信息卡片 ──
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: infoColumn.implicitHeight + 32
        color: Theme.bg_card; radius: 12
        border.color: Theme.border_default; border.width: 1

        ColumnLayout {
            id: infoColumn
            anchors.left: parent.left; anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20
            spacing: 14

            InfoRow { label: qsTr("用户名"); value: Api.username || "---" }
            InfoRow { label: qsTr("邮箱");   value: Api.email    || "---" }
            InfoRow { label: qsTr("状态");   value: qsTr("已登录"); valueColor: Theme.success_fg }
        }
    }

    // ── 关联第三方账号 ──
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("关联第三方账号") + " ›"
        color: Theme.accent_text; font.pixelSize: 16
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
        text: qsTr("退出登录")
        variant: "danger"
        font.pixelSize: 17; font.weight: Font.Bold
        onClicked: root.logoutClicked()
    }

    component InfoRow: RowLayout {
        property string label: ""
        property string value: ""
        property color valueColor: Theme.text_primary
        Layout.fillWidth: true; spacing: 12
        Text { Layout.preferredWidth: implicitWidth + 16; text: label; color: Theme.text_secondary; font.pixelSize: 16; font.family: "Microsoft YaHei UI" }
        Text { Layout.fillWidth: true; text: value; color: valueColor; font.pixelSize: 16; font.weight: Font.DemiBold; font.family: "Microsoft YaHei UI"; elide: Text.ElideRight }
    }
}
