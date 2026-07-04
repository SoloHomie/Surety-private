import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"
import Surety 1.0
import "../../toast"
import "auth"
import "."

ScrollPage {
    id: panel
    contentAlignment: Qt.AlignHCenter
    property int    countdown: 0

    Timer { id: ct; interval: 1000; repeat: true; onTriggered: { panel.countdown--; if(panel.countdown<=0) ct.stop() } }

    function clearAll() { panel.countdown = 0; ct.stop(); loginForm.clear(); registerForm.reset(); resetForm.clear() }

    // ── Auth 信号 ──
    Connections {
        target: Auth
        function onLoginResult(ok, msg) {
            loginForm.loading = false
            if (ok) {
                loginForm.clear()
                ToastManager.add(qsTr("欢迎回来！"), "success", qsTr("登录成功"), 3000)
                Api.fetchStats()
                stack.currentIndex = 4
            }
            else ToastManager.add(msg || qsTr("登录失败"), "error", qsTr("登录失败"), 3000)
        }
        function onRegisterResult(ok, msg) {
            registerForm.loading = false
            if (ok) { registerForm.reset(); stack.currentIndex = 0; ToastManager.add(qsTr("注册成功，快登录体验吧！"), "success", qsTr("欢迎加入"), 3000) }
            else ToastManager.add(msg || qsTr("注册失败"), "error", qsTr("注册失败"), 3000)
        }
        function onSendCodeResult(ok, msg) { if (!ok) ToastManager.add(msg || qsTr("发送失败"), "error", qsTr("请重试"), 3000) }
        function onResetPasswordResult(ok, msg) {
            resetForm.loading = false
            if (ok) { stack.currentIndex = 0; ToastManager.add(qsTr("密码重置成功，请重新登录"), "success", qsTr("密码已更新"), 4000) }
            else ToastManager.add(msg || qsTr("重置失败"), "error", qsTr("重置失败"), 3000)
        }
        function onOauthUrlReady(url) {
            if (url) { Qt.openUrlExternally(url); ToastManager.add(qsTr("跳转授权中..."), "info", qsTr("第三方登录"), 3000) }
            else ToastManager.add(qsTr("授权暂不可用"), "error", qsTr("请确认后端已启动"), 4000)
        }
    }
    Connections {
        target: OAuthServer
        function onOauthReceived(json) {
            var data = JSON.parse(json)
            if (data.mode === "bind") {
                ToastManager.add(qsTr("绑定成功！"), "success", data.provider || "", 3000)
                Api.setAuth(json); Api.fetchStats(); Api.fetchOAuthLinks()
            } else {
                loginForm.clear()
                ToastManager.add(qsTr("欢迎回来！"), "success", qsTr("登录成功"), 3000)
                Api.setAuth(json); Api.fetchStats()
                stack.currentIndex = 4
            }
        }
    }

    // 自动登录成功 → 显示 LoginSuccess
    Connections {
        target: Api
        function onAutoLoginFinished(ok) { if (ok) stack.currentIndex = 4 }
    }
    Component.onCompleted: { if (Api.isLoggedIn) stack.currentIndex = 4 }

    // ── Logo ──
    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 32; spacing: 12
        Image { Layout.alignment: Qt.AlignHCenter; width: 50; height: 50; sourceSize.width: 108; sourceSize.height: 108; fillMode: Image.PreserveAspectFit; source: "qrc:/qml/images/cookie.svg" }
        Text { Layout.alignment: Qt.AlignHCenter; text: "Surety"; color: Theme.text_primary; font.pixelSize: 24; font.weight: Font.Bold; font.family: "Microsoft YaHei UI" }
    }

    // ── 页面栈 ──
    StackLayout {
        id: stack
        Layout.fillWidth: true
        currentIndex: 0

        // 0 - 登录
        LoginForm {
            id: loginForm
            Layout.fillWidth: true
            onLoginClicked: function(email, pwd, remember) {
                if (email === "" || pwd === "") { ToastManager.add(qsTr("请填写邮箱和密码"), "warning", qsTr("提示"), 2000); return }
                loginForm.loading = true; Auth.login(email, pwd, remember)
            }
            onForgotPassword: { clearAll(); stack.currentIndex = 2 }
            onSwitchToRegister: { clearAll(); stack.currentIndex = 1 }
        }

        // 1 - 注册
        RegisterForm {
            id: registerForm
            Layout.fillWidth: true
            countdown: panel.countdown
            onSendCodeRequested: function(email) {
                if (email === "" || email.indexOf("@") < 0) { ToastManager.add(qsTr("请输入有效邮箱"), "warning", qsTr("提示"), 2000); return }
                panel.countdown = 60; ct.start(); Auth.sendCode(email, "register")
            }
            onSwitchToLogin: { clearAll(); stack.currentIndex = 0 }
            onRegisterClicked: function(email, username, password, confirm, code) {
                if (password !== confirm) { ToastManager.add(qsTr("两次密码不一致"), "warning", qsTr("提示"), 2000); return }
                registerForm.loading = true; Auth.registerUser(email, password, code)
            }
        }

        // 2 - 重置密码
        ResetPasswordForm {
            id: resetForm
            Layout.fillWidth: true
            countdown: panel.countdown
            onSendCodeRequested: function(email) {
                if (email === "" || email.indexOf("@") < 0) { ToastManager.add(qsTr("请输入有效邮箱"), "warning", qsTr("提示"), 2000); return }
                panel.countdown = 60; ct.start(); Auth.sendCode(email, "reset")
            }
            onBackToLogin: { clearAll(); stack.currentIndex = 0 }
            onResetRequested: function(email, code, newPwd, confirm) {
                if (newPwd !== confirm) { ToastManager.add(qsTr("两次密码不一致"), "warning", qsTr("提示"), 2000); return }
                resetForm.loading = true; Auth.resetPassword(email, code, newPwd)
            }
        }

        // 3 - (空，第三方登录移到外面)
        Item { Layout.fillWidth: true; visible: false }

        // 4 - 登录成功
        LoginSuccess {
            Layout.fillWidth: true
            onLogoutClicked: {
                Auth.logout()
                AssetModel.clear()
                SubModel.clear()
                MarketModel.clear()
                stack.currentIndex = 0
            }
            onLinkAccountsClicked: {
                if (Api.provider === "password") {
                    stack.currentIndex = 5  // 密码登录 → 关联页
                } else {
                    ToastManager.add(qsTr("请先创建账号密码"), "warning", qsTr("提示"), 5000)
                    stack.currentIndex = 1  // OAuth 登录 → 注册页
                }
            }
        }

        // 5 - 第三方账号绑定
        LinkedAccounts {
            id: linkedAccounts
            Layout.fillWidth: true
            onBackToLogin: stack.currentIndex = 4
        }
    }

    // 第三方登录 — 始终可见（成功页除外）
    ThirdPartyLogin {
        visible: stack.currentIndex !== 4
        Layout.fillWidth: true
        onProviderClicked: function(name) {
            var port = OAuthServer && OAuthServer.port ? OAuthServer.port : 0
            Auth.getOAuthUrl(name.toLowerCase(), port)
        }
    }
}
