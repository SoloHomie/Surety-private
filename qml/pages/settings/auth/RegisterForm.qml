import QtQuick
import "../../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../../baseComponents"

ColumnLayout {
    id: root; Layout.fillWidth: true; spacing: 18

    property int countdown: 0
    property bool codeSent: false; property bool loading: false
    property alias sendingCode: sendCodeBtn.sending

    signal registerClicked(string email, string username, string password, string confirmPassword, string code)
    signal sendCodeRequested(string email); signal switchToLogin()

    function reset() { regEmail.text=""; regCode.text=""; regPassword.text=""; regConfirm.text="" }

    readonly property bool _emailTouched: regEmail.text !== ""
    readonly property bool _emailFormat: _emailTouched && regEmail.text.indexOf("@") > 0
        && regEmail.text.indexOf(".", regEmail.text.indexOf("@")) > regEmail.text.indexOf("@") + 1
    readonly property bool _codeTouched: regCode.text !== ""
    readonly property bool _codeOk: _codeTouched && regCode.text.trim().length >= 4
    readonly property bool _pwNotEmpty: regPassword.text !== ""
    readonly property bool _pwNoSpace: regPassword.text.indexOf(" ") < 0
    readonly property bool _pwLength: regPassword.text.length >= 6 && regPassword.text.length <= 20
    readonly property bool _pwHasLetter: /[a-zA-Z]/.test(regPassword.text)
    readonly property bool _pwHasDigit: /[0-9]/.test(regPassword.text)
    readonly property bool _pwHasBoth: _pwHasLetter && _pwHasDigit
    readonly property bool _confirmTouched: regConfirm.text !== ""
    readonly property bool _pwMatch: _confirmTouched && regPassword.text === regConfirm.text
    readonly property bool _formValid: _emailFormat && _codeOk && _pwNotEmpty && _pwNoSpace && _pwLength && _pwHasBoth && _pwMatch

    readonly property int _strength: { if (!_pwNotEmpty||!_pwLength||!_pwHasBoth) return 0; if (regPassword.text.length>=12) return 2; if (regPassword.text.length>=8) return 1; return 0 }
    readonly property var _strengthLabel: [qsTr("弱"), qsTr("中"), qsTr("强")]
    readonly property var _strengthColor: [Theme.danger_fg, Theme.warning_fg, Theme.success_fg]

    SuretyTextField { id: regEmail; Layout.fillWidth: true; placeholder: qsTr("请输入邮箱地址") }
    Text { visible: _emailTouched && !_emailFormat; text: qsTr("· 邮箱格式不正确"); color: Theme.danger_fg; font.pixelSize: 13; font.family: "Microsoft YaHei UI" }

    RowLayout { Layout.fillWidth: true; spacing: 12
        SuretyTextField { id: regCode; Layout.fillWidth: true; placeholder: qsTr("请输入邮箱验证码") }
        SendCodeButton { id: sendCodeBtn; countdown: root.countdown; onClicked: { if (!_emailFormat) return; root.sendCodeRequested(regEmail.text) } }
    }
    Text { visible: _codeTouched && !_codeOk; text: qsTr("· 验证码至少 4 位"); color: Theme.danger_fg; font.pixelSize: 13; font.family: "Microsoft YaHei UI" }

    PasswordField { id: regPassword; Layout.fillWidth: true; placeholder: qsTr("请输入密码（6-20 位，需含字母+数字）") }

    RowLayout { visible: _pwNotEmpty; Layout.fillWidth: true; spacing: 4
        Repeater { model: 3; Rectangle { Layout.fillWidth: true; height: 4; radius: 2
            color: index < root._strength + 1 ? _strengthColor[root._strength] : Theme.border_default
            Behavior on color { ColorAnimation { duration: 200 } } } }
        Text { visible: _pwNotEmpty; text: _strengthLabel[root._strength]; color: _strengthColor[root._strength]
            font.pixelSize: 14; font.weight: Font.DemiBold; font.family: "Microsoft YaHei UI"; Layout.leftMargin: 8 }
    }

    ColumnLayout { visible: _pwNotEmpty && !(_pwNoSpace && _pwLength && _pwHasBoth); spacing: 2
        Repeater { model: [
            { ok: root._pwNoSpace, msg: qsTr("· 密码不能包含空格") },
            { ok: root._pwLength, msg: qsTr("· 密码长度 6-20 位") },
            { ok: root._pwHasLetter, msg: qsTr("· 需包含至少一个字母") },
            { ok: root._pwHasDigit, msg: qsTr("· 需包含至少一个数字") }
        ]; delegate: Text { visible: !modelData.ok; text: modelData.msg; color: Theme.danger_fg; font.pixelSize: 13; font.family: "Microsoft YaHei UI" } }
    }

    SuretyTextField { id: regConfirm; Layout.fillWidth: true; placeholder: qsTr("请再次输入密码"); echoMode: TextInput.Password }
    Text { visible: _confirmTouched && !_pwMatch; text: qsTr("· 两次输入的密码不一致"); color: Theme.danger_fg; font.pixelSize: 13; font.family: "Microsoft YaHei UI" }

    SuretyBtn { Layout.fillWidth: true; Layout.topMargin: 4; Layout.preferredHeight: 48
        text: (root.loading && _formValid) ? qsTr("注册中...") : qsTr("注册")
        variant: "primary"; enabled: _formValid && !root.loading; font.weight: Font.Bold
        onClicked: root.registerClicked(regEmail.text, regEmail.text, regPassword.text, regConfirm.text, regCode.text) }

    // 底部链接 — 大厂风格：纯文字可点击
    RowLayout { Layout.alignment: Qt.AlignHCenter; spacing: 4
        Text { text: qsTr("已有账号？"); color: Theme.text_secondary; font.pixelSize: 14; font.family: "Microsoft YaHei UI" }
        Text { text: qsTr("登录"); color: Theme.accent_text; font.pixelSize: 14; font.family: "Microsoft YaHei UI"
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.switchToLogin() } }
    }

    Text { Layout.alignment: Qt.AlignHCenter
        text: qsTr("注册即表示同意") + " <a href='#'>" + qsTr("服务条款") + "</a> " + qsTr("和") + " <a href='#'>" + qsTr("隐私政策") + "</a>"
        color: Theme.text_secondary; font.pixelSize: 13; font.family: "Microsoft YaHei UI"; textFormat: Text.RichText }
}
