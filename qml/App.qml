import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "layout"
import "toast"
import "themes"

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

    // 更新检查结果 ── 有新版弹 popup
    Connections {
        target: Api
        function onUpdateCheckFinished(hasUpdate, latest, url) {
            if (hasUpdate) {
                updatePopup.latestVer = latest
                updatePopup.downloadUrl = url
                updatePopup.open()
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

        // ── 更新通知 Popup ──
        Popup {
            id: updatePopup
            x: mainRect.width - width - 32
            y: 32
            width: 380
            padding: 24
            closePolicy: Popup.CloseOnEscape
            modal: false

            property string latestVer: ""
            property string downloadUrl: ""

            background: Rectangle {
                color: "#161b22"
                radius: 12
                border.width: 1; border.color: "#30363d"
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 标题行
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12

                    Rectangle {
                        width: 8; height: 8; radius: 4; color: "#d29922"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "发现新版本"
                        color: "#e6edf3"
                        font.pixelSize: 16; font.weight: Font.Bold
                        font.family: "Microsoft YaHei UI"
                    }
                    Text {
                        text: "×"
                        color: "#8b949e"; font.pixelSize: 18
                        font.family: "Microsoft YaHei UI"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: updatePopup.close()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    text: "Surety v" + updatePopup.latestVer + " 已发布。\n建议更新以获得最新功能和安全修复。"
                    color: "#8b949e"
                    font.pixelSize: 13; lineHeight: 1.5
                    font.family: "Microsoft YaHei UI"
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        height: 32; width: dismissText.implicitWidth + 24; radius: 6
                        color: "#21262d"
                        Text {
                            id: dismissText
                            anchors.centerIn: parent
                            text: "稍后提醒"
                            color: "#8b949e"
                            font.pixelSize: 13; font.family: "Microsoft YaHei UI"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: updatePopup.close()
                        }
                    }

                    Rectangle {
                        height: 32; width: downloadText.implicitWidth + 24; radius: 6
                        color: "#1f6feb"
                        Text {
                            id: downloadText
                            anchors.centerIn: parent
                            text: "前往下载"
                            color: "#ffffff"
                            font.pixelSize: 13; font.weight: Font.Bold
                            font.family: "Microsoft YaHei UI"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (updatePopup.downloadUrl !== "")
                                    Qt.openUrlExternally(updatePopup.downloadUrl)
                                updatePopup.close()
                            }
                        }
                    }
                }
            }
        }
    }

    function defocus() { mainRect.forceActiveFocus() }
}
