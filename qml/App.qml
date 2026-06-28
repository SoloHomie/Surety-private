import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "layout"
import "toast"
import "themes"
import "popups"

Window {
    id: window
    width: 1600
    height: 1000
    minimumWidth: 940
    minimumHeight: 600

    visible: true
    color: Theme.bg_input
    title: "Surety"

    // OAuth 回调 → C++ 保存令牌
    Connections {
        target: OAuthServer
        function onOauthReceived(json) {
            Api.setAuth(json); Api.fetchStats()
            var data = JSON.parse(json)
            if (data.mode === "bind") Api.fetchOAuthLinks()
        }
    }

    // 自动登录结果（记住我）
    Connections {
        target: Api
        function onAutoLoginFinished(ok) {
            if (ok) { ToastManager.add("自动登录成功", "success", "欢迎回来", 3000); Api.fetchStats(); Api.checkUpdate() }
        }
    }

    // 更新检查结果 ── 传递真实数据给弹窗
    Connections {
        target: Api
        function onUpdateCheckFinished(info) {
            if (info && info.hasUpdate) {
                updateContent.currentVer = info.currentVer || ""
                updateContent.latestVer = info.latestVer || ""
                updateContent.releaseNotes = info.changelog || ""
                updateContent.githubUrl = info.githubUrl || ""
                updateContent.mirrorUrl = info.mirrorUrl || ""
                updateDialog.open()
            }
        }
    }

    Component.onCompleted: {
        mainRect.scale = 0.96
        mainRect.opacity = 0
        mainRect.scale = 1.0
        mainRect.opacity = 1.0
        ToastManager.target = toastHost
        if (Api.isLoggedIn) ToastManager.add("自动登录成功", "success", "欢迎回来", 3000)
    }

    component ToastContainer: Item {
        id: host
        anchors.fill: parent
        z: 9999

        ListModel { id: toastModel }

        function add(message, type, title, duration) {
            toastModel.append({
                msg: message || "",
                tp:  type    || "info",
                ttl: title   || "",
                dur: (duration !== undefined) ? duration : 3000,
                id:  Date.now() + Math.random()  // unique toastId for stable removal
            })
        }

        Column {
            id: toastColumn
            anchors.right:  parent.right;   anchors.rightMargin: 24
            anchors.bottom: parent.bottom;  anchors.bottomMargin: 24
            width: 600
            spacing: 14

            Repeater {
                model: toastModel
                delegate: ToastItem {
                    toastType:  model.tp  || "info"
                    message:    model.msg || ""
                    title:      model.ttl || ""
                    duration:   model.dur || 5000

                    readonly property var toastId: model.id

                    Component.onCompleted: { x = 0; opacity = 1; scale = 1.0 }
                    x: 140; opacity: 0; scale: 0.9

                    Behavior on x       { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                    Behavior on scale   { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }

                    onDismissed: {
                        if (exitLock) return
                        exitLock = true; opacity = 0; scale = 0.9
                        exitTimer.start()
                    }

                    property bool exitLock: false

                    Timer {
                        id: exitTimer; interval: 200
                        onTriggered: {
                            for (var i = 0; i < toastModel.count; i++) {
                                if (toastModel.get(i).id === toastId) {
                                    toastModel.remove(i);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: mainRect
        color: Theme.bg_input
        anchors.fill: parent

        Behavior on scale   { NumberAnimation { duration: 380; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 330; easing.type: Easing.OutCubic } }

        SideBar {
            id: sideBar
            width: 280
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            selectedIndex: displayRect.pageIndex
            onPageSwitchRequested: function(idx) { displayRect.switchTo(idx) }
        }

        DisplayRect {
            id: displayRect
            anchors.left: sideBar.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        ToastContainer { id: toastHost }

        // ── 更新通知弹窗 ──
        Dialog {
            id: updateDialog
            modal: true
            closePolicy: Popup.CloseOnEscape
            standardButtons: Dialog.NoButton
            width: 650
            height: 880
            x: (window.width  - width)  / 2
            y: (window.height - height) / 2
            padding: 0

            background: Rectangle { color: "transparent" }

            Overlay.modal: Rectangle {
                color: "#0d1117"
                opacity: 0.85
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            UpdateContent {
                id: updateContent
                onDismissClicked: updateDialog.close()
            }
        }
    }

    function defocus() { mainRect.forceActiveFocus() }
}
