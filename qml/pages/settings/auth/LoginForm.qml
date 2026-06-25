import QtQuick
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
        placeholder: "邮箱地址"
        font.pixelSize: 17
    }

    PasswordField {
        id: loginPassword
        Layout.fillWidth: true
        placeholder: "密码"
        font.pixelSize: 17
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        SuretySwitch {
            id: rememberSwitch
            label: "保存登录信息"
            scale: 1.5
            transformOrigin: Item.Left
            checked: true  // 默认记住，抖音风格
        }
        Item { Layout.fillWidth: true }
        Text {
            text: "忘记密码？"; color: "#58a6ff"; font.pixelSize: 15
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
        text: root.loading ? "登录中..." : "登  录"
        variant: "primary"
        enabled: !root.loading
        font.pixelSize: 19; font.weight: Font.Bold
        onClicked: root.loginClicked(loginEmail.text, loginPassword.text, rememberSwitch.checked)
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 4
        text: "还没有账号？<a href='#'>注册</a>"
        color: "#8b949e"; font.pixelSize: 15; font.family: "Microsoft YaHei UI"
        textFormat: Text.RichText
        onLinkActivated: root.switchToRegister()
    }
}
