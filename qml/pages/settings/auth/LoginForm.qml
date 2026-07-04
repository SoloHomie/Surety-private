import QtQuick
import "../../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../../baseComponents"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 20

    signal loginClicked(string email, string password, bool rememberMe)
    signal forgotPassword()
    signal switchToRegister()
    property alias rememberMe: rememberSwitch.checked
    property bool loading: false

    function clear() {
        loginEmail.text = ""
        loginPassword.text = ""
        rememberSwitch.checked = false
    }

    SuretyTextField {
        id: loginEmail
        Layout.fillWidth: true
        placeholder: qsTr("邮箱地址")
        font.pixelSize: 17
    }

    PasswordField {
        id: loginPassword
        Layout.fillWidth: true
        placeholder: qsTr("密码")
        font.pixelSize: 17
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        SuretySwitch {
            id: rememberSwitch
            label: qsTr("保存登录信息")
            scale: 1.5
            transformOrigin: Item.Left
            checked: true  // 默认记住，抖音风格
        }
        Item { Layout.fillWidth: true }
        Text {
            text: qsTr("忘记密码？")
            color: Theme.accent_text; font.pixelSize: 15
            font.family: "Microsoft YaHei UI"
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: root.forgotPassword()
            }
        }
    }

    SuretyBtn {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.preferredHeight: 52
        text: root.loading ? qsTr("登录中...") : qsTr("登录")
        variant: "primary"
        enabled: !root.loading
        font.pixelSize: 19; font.weight: Font.Bold
        onClicked: root.loginClicked(loginEmail.text, loginPassword.text, rememberSwitch.checked)
    }

    RowLayout { Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 4; spacing: 4
        Text { text: qsTr("还没有账号？"); color: Theme.text_secondary; font.pixelSize: 14; font.family: "Microsoft YaHei UI" }
        Text { text: qsTr("去注册"); color: Theme.accent_text; font.pixelSize: 14; font.family: "Microsoft YaHei UI"
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.switchToRegister() } }
    }
}
