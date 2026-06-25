import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../baseComponents"

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 18

    property int countdown: 0
    property bool codeSent: false
    property bool loading: false
    property alias sendingCode: sendCodeBtn.sending

    signal resetRequested(string email, string code, string newPassword, string confirmPassword)
    signal sendCodeRequested(string email)
    signal backToLogin()

    function clear() {
        resetEmail.text = ""
        resetCode.text = ""
        resetNewPassword.text = ""
        resetConfirm.text = ""
    }

    Text {
        text: "请输入您的邮箱，获取验证码后即可在本页面重置密码。"
        color: "#8b949e"; font.pixelSize: 14; font.family: "Microsoft YaHei UI"
        wrapMode: Text.WordWrap; Layout.fillWidth: true
    }

    SuretyTextField {
        id: resetEmail; Layout.fillWidth: true; placeholder: "邮箱地址"
    }

    // 验证码：输入框 + 发送按钮
    RowLayout {
        Layout.fillWidth: true; spacing: 12
        SuretyTextField {
            id: resetCode; Layout.fillWidth: true; placeholder: "请输入验证码"
        }
        SendCodeButton {
            id: sendCodeBtn
            countdown: root.countdown
            onClicked: root.sendCodeRequested(resetEmail.text)
        }
    }

    PasswordField {
        id: resetNewPassword; Layout.fillWidth: true; placeholder: "新密码（至少 8 位）"
    }

    SuretyTextField {
        id: resetConfirm; Layout.fillWidth: true; placeholder: "确认新密码"
        echoMode: TextInput.Password
    }

    SuretyBtn {
        Layout.fillWidth: true; Layout.topMargin: 4
        Layout.preferredHeight: 48
        text: root.loading ? "重置中..." : "重置密码"
        variant: "primary"
        enabled: !root.loading
        font.weight: Font.Bold
        onClicked: root.resetRequested(resetEmail.text, resetCode.text, resetNewPassword.text, resetConfirm.text)
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "← 返回登录"; color: "#58a6ff"; font.pixelSize: 13
        font.family: "Microsoft YaHei UI"
        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: root.backToLogin()
        }
    }
}
