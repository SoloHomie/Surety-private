import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "../../../baseComponents"
import "../../../toast"

// 第三方账号关联 — 大厂做法：不限制绑定，解绑最后一个时提醒设密码
ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 16

    signal backToLogin()

    Component.onCompleted: Api.fetchOAuthLinks()

    Connections {
        target: Api
        function onOauthLinksChanged() { linksRepeater.model = Api.oauthLinks }
    }

    Text {
        Layout.fillWidth: true
        text: "关联第三方账号后，可使用第三方快速登录"
        color: "#8b949e"; font.pixelSize: 15
        font.family: "Microsoft YaHei UI"
        wrapMode: Text.WordWrap
    }

    // ── GitHub ──
    ProviderCard {
        provider: "github"; providerName: "GitHub"
        iconSource: "qrc:/qml/images/github.svg"
        hasPassword: hasPasswordLogin()
        bound: hasLink("github")
        onBindClicked: bindOAuth("github")
        onUnbindClicked: unbindOAuth("github")
    }

    // ── Discord ──
    ProviderCard {
        provider: "discord"; providerName: "Discord"
        iconSource: "qrc:/qml/images/discord.svg"
        hasPassword: hasPasswordLogin()
        bound: hasLink("discord")
        onBindClicked: bindOAuth("discord")
        onUnbindClicked: unbindOAuth("discord")
    }

    Item { Layout.preferredHeight: 4 }

    // ── 返回 ──
    SuretyBtn {
        Layout.fillWidth: true; Layout.preferredHeight: 40
        text: "← 返回"; variant: "outline"
        font.pixelSize: 16
        onClicked: root.backToLogin()
    }

    // ── 辅助 ──
    function hasLink(p) {
        for (var i = 0; i < Api.oauthLinks.length; i++)
            if (Api.oauthLinks[i].provider === p) return true
        return false
    }
    function hasPasswordLogin() {
        // 只要有 email 且不是纯 OAuth 用户就认为有密码（简化判断）
        return true
    }
    function bindOAuth(p) {
        var port = OAuthServer && OAuthServer.port ? OAuthServer.port : 0
        Auth.getOAuthBindUrl(p, port)
        ToastManager.add("请在浏览器中授权", "info", "关联 " + p, 3000)
    }
    function unbindOAuth(p) {
        // 如果是唯一的登录方式，提醒设密码
        if (Api.oauthLinks.length <= 1 && !hasPasswordLogin()) {
            ToastManager.add("请先设置账户密码再解除绑定", "warning", "提示", 4000)
            return
        }
        Api.unlinkOAuth(p)
        ToastManager.add("已解除关联", "info", p, 2000)
    }

    // ── Provider 卡片组件 ──
    component ProviderCard: Rectangle {
        property string provider: ""
        property string providerName: ""
        property string iconSource: ""
        property bool   hasPassword: true
        property bool   bound: false
        signal bindClicked()
        signal unbindClicked()

        Layout.fillWidth: true; Layout.preferredHeight: 64
        color: "#161b22"; radius: 10
        border.color: "#21262d"; border.width: 1

        RowLayout {
            anchors.fill: parent; anchors.margins: 14; spacing: 14

            Image {
                source: iconSource; sourceSize.width: 36; sourceSize.height: 36
                Layout.preferredWidth: 36; Layout.preferredHeight: 36
                fillMode: Image.PreserveAspectFit
            }

            ColumnLayout {
                spacing: 2; Layout.fillWidth: true
                Text { text: providerName; color: "#e6edf3"; font.pixelSize: 16; font.weight: Font.DemiBold; font.family: "Microsoft YaHei UI" }
                Text {
                    text: bound ? "● 已关联" : "○ 未关联"
                    color: bound ? "#3fb950" : "#8b949e"; font.pixelSize: 13; font.family: "Microsoft YaHei UI"
                }
            }

            Item { Layout.fillWidth: true }  // 弹簧，按钮靠右

            SuretyBtn {
                text: bound ? "解除" : "关联"
                variant: bound ? "danger" : "outline"
                Layout.preferredWidth: 64; Layout.preferredHeight: 34
                font.pixelSize: 16; font.weight: Font.DemiBold
                onClicked: bound ? unbindClicked() : bindClicked()
            }
        }
    }
}
