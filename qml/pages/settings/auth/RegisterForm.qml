import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../baseComponents"

// ═══════════════════════════════════════════════════════════════════════
//  RegisterForm — 注册表单（纯 QML 本地实时校验）
//  校验:
//    · 邮箱格式 (xx@xx.xx)
//    · 验证码非空
//    · 密码 6-20 位，不含空格，必须含字母 + 数字
//    · 两次密码一致
//  密码强度: 弱(纯数字/字母) / 中(字母+数字,≥8位) / 强(字母+数字,≥12位)
// ═══════════════════════════════════════════════════════════════════════
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 18

    property int countdown: 0
    property bool codeSent: false
    property bool loading: false
    property alias sendingCode: sendCodeBtn.sending

    signal registerClicked(string email, string username, string password, string confirmPassword, string code)
    signal sendCodeRequested(string email)
    signal switchToLogin()

    function reset() {
        regEmail.text = ""
        regCode.text = ""
        regPassword.text = ""
        regConfirm.text = ""
    }

    // ═══════════════════════════════════════════════
    //  校验逻辑
    // ═══════════════════════════════════════════════

    // ── 邮箱 ──
    readonly property bool _emailTouched: regEmail.text !== ""
    readonly property bool _emailFormat:  _emailTouched
        && regEmail.text.indexOf("@") > 0
        && regEmail.text.indexOf(".", regEmail.text.indexOf("@")) > regEmail.text.indexOf("@") + 1

    // ── 验证码 ──
    readonly property bool _codeTouched: regCode.text !== ""
    readonly property bool _codeOk:      _codeTouched && regCode.text.trim().length >= 4

    // ── 密码 ──
    readonly property bool _pwNotEmpty:  regPassword.text !== ""
    readonly property bool _pwNoSpace:   regPassword.text.indexOf(" ") < 0
    readonly property bool _pwLength:    regPassword.text.length >= 6 && regPassword.text.length <= 20
    readonly property bool _pwHasLetter: /[a-zA-Z]/.test(regPassword.text)
    readonly property bool _pwHasDigit:  /[0-9]/.test(regPassword.text)
    readonly property bool _pwHasBoth:   _pwHasLetter && _pwHasDigit

    // ── 确认密码 ──
    readonly property bool _confirmTouched: regConfirm.text !== ""
    readonly property bool _pwMatch:        _confirmTouched && regPassword.text === regConfirm.text

    // ── 总校验 ──
    readonly property bool _formValid: _emailFormat && _codeOk && _pwNotEmpty
                                       && _pwNoSpace && _pwLength && _pwHasBoth && _pwMatch

    // ═══════════════════════════════════════════════
    //  密码强度
    // ═══════════════════════════════════════════════
    readonly property int _strength: {
        if (!_pwNotEmpty || !_pwLength || !_pwHasBoth) return 0
        if (regPassword.text.length >= 12) return 2
        if (regPassword.text.length >= 8)  return 1
        return 0
    }
    readonly property var _strengthLabel: ["弱", "中", "强"]
    readonly property var _strengthColor: ["#f85149", "#d29922", "#3fb950"]

    // ═══════════════════════════════════════════════
    //  邮箱
    // ═══════════════════════════════════════════════
    SuretyTextField {
        id: regEmail
        Layout.fillWidth: true
        placeholder: "请输入邮箱地址"
    }

    Text {
        visible: _emailTouched && !_emailFormat
        text: "· 邮箱格式不正确"
        color: "#f85149"; font.pixelSize: 13
        font.family: "Microsoft YaHei UI"
    }

    // ═══════════════════════════════════════════════
    //  验证码
    // ═══════════════════════════════════════════════
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        SuretyTextField {
            id: regCode
            Layout.fillWidth: true
            placeholder: "请输入邮箱验证码"
        }

        SendCodeButton {
            id: sendCodeBtn
            countdown: root.countdown
            onClicked: {
                if (!_emailFormat) return
                root.sendCodeRequested(regEmail.text)
            }
        }
    }

    Text {
        visible: _codeTouched && !_codeOk
        text: "· 验证码至少 4 位"
        color: "#f85149"; font.pixelSize: 13
        font.family: "Microsoft YaHei UI"
    }

    // ═══════════════════════════════════════════════
    //  密码
    // ═══════════════════════════════════════════════
    PasswordField {
        id: regPassword
        Layout.fillWidth: true
        placeholder: "请输入密码（6-20 位，需含字母+数字）"
    }

    // ── 强度条 ──
    RowLayout {
        visible: _pwNotEmpty
        Layout.fillWidth: true; spacing: 4

        Repeater {
            model: 3
            Rectangle {
                Layout.fillWidth: true
                height: 4; radius: 2
                color: index < root._strength + 1 ? _strengthColor[root._strength] : "#21262d"
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        Text {
            visible: _pwNotEmpty
            text: _strengthLabel[root._strength]
            color: _strengthColor[root._strength]
            font.pixelSize: 14; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI"
            Layout.leftMargin: 8
        }
    }

    // ── 密码错误提示 ──
    ColumnLayout {
        visible: _pwNotEmpty && !(_pwNoSpace && _pwLength && _pwHasBoth)
        spacing: 2

        Repeater {
            model: [
                { ok: root._pwNoSpace,   msg: "· 密码不能包含空格" },
                { ok: root._pwLength,    msg: "· 密码长度 6-20 位" },
                { ok: root._pwHasLetter, msg: "· 需包含至少一个字母" },
                { ok: root._pwHasDigit,  msg: "· 需包含至少一个数字" }
            ]
            delegate: Text {
                visible: !modelData.ok
                text: modelData.msg
                color: "#f85149"; font.pixelSize: 13
                font.family: "Microsoft YaHei UI"
            }
        }
    }

    // ═══════════════════════════════════════════════
    //  确认密码
    // ═══════════════════════════════════════════════
    SuretyTextField {
        id: regConfirm
        Layout.fillWidth: true
        placeholder: "请再次输入密码"
        echoMode: TextInput.Password
    }

    Text {
        visible: _confirmTouched && !_pwMatch
        text: "· 两次输入的密码不一致"
        color: "#f85149"; font.pixelSize: 13
        font.family: "Microsoft YaHei UI"
    }

    // ═══════════════════════════════════════════════
    //  提交
    // ═══════════════════════════════════════════════
    SuretyBtn {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.preferredHeight: 48
        text: (root.loading && _formValid) ? "注册中..." : "注  册"
        variant: "primary"
        enabled: _formValid && !root.loading
        font.weight: Font.Bold
        onClicked: root.registerClicked(regEmail.text, regEmail.text,
                                        regPassword.text, regConfirm.text, regCode.text)
    }

    // ═══════════════════════════════════════════════
    //  底部链接
    // ═══════════════════════════════════════════════
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "已有账号？<a href='#'>登录</a>"
        color: "#8b949e"; font.pixelSize: 14; font.family: "Microsoft YaHei UI"
        textFormat: Text.RichText
        onLinkActivated: root.switchToLogin()
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "注册即表示同意 <a href='#'>服务条款</a> 和 <a href='#'>隐私政策</a>"
        color: "#8b949e"; font.pixelSize: 13; font.family: "Microsoft YaHei UI"
        textFormat: Text.RichText
        onLinkActivated: console.log("Terms link clicked")
    }
}
