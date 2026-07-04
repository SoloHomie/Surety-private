import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../themes"

Window {
    id: updaterWin
    width: 680; height: 460
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    // ── 拖动 ──
    MouseArea {
        anchors.fill: parent
        property point lastPos: Qt.point(0, 0)
        onPressed: lastPos = Qt.point(mouseX, mouseY)
        onPositionChanged: {
            updaterWin.x += mouseX - lastPos.x
            updaterWin.y += mouseY - lastPos.y
        }
    }

    property string version: ""
    property int progress: 0
    property bool installing: false

    // ── 退出动画 ──
    function dismiss() {
        exitTimer.start()
    }

    Timer {
        id: exitTimer
        interval: 600
        onTriggered: updaterWin.close()
    }

    // ── 主卡片 ──
    Rectangle {
        id: card
        anchors.fill: parent; anchors.margins: 16
        radius: 20
        color: "#0d1117"
        border.width: 1
        border.color: Qt.rgba(0.30, 0.54, 0.95, 0.20)

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#1f6feb"
            shadowOpacity: 0.30
            shadowBlur: 50
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 16
        }

        // ── 关闭按钮 ──
        Rectangle {
            anchors.top: parent.top; anchors.right: parent.right
            anchors.topMargin: 14; anchors.rightMargin: 14
            width: 28; height: 28; radius: 14
            color: closeMa.containsMouse ? "#30363d" : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
            Text {
                anchors.centerIn: parent
                text: "×"; color: "#8b949e"; font.pixelSize: 18
                font.family: "Microsoft YaHei UI"
            }
            MouseArea {
                id: closeMa; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: updaterWin.dismiss()
            }
        }

        // ── 顶部装饰光晕 ──
        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.2; color: "#1f6feb" }
                GradientStop { position: 0.5; color: "#58a6ff" }
                GradientStop { position: 0.8; color: "#1f6feb" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // ── 背景微光 ──
        Rectangle {
            anchors.centerIn: parent
            width: 240; height: 240; radius: 120
            color: "#1f6feb"
            opacity: 0.03
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40

            Item { Layout.fillHeight: true }

            // ── Logo 区域 ──
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 100; Layout.preferredHeight: 100
                Layout.bottomMargin: 28

                // 旋转光环
                Rectangle {
                    anchors.fill: parent; radius: 50
                    color: "transparent"
                    border.width: 2; border.color: "#1f6feb"
                    opacity: 0.3
                    RotationAnimation on rotation {
                        from: 0; to: 360; duration: 3000
                        running: !installing
                        loops: Animation.Infinite; easing.type: Easing.Linear
                    }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 92; height: 92; radius: 46
                    color: "#161b22"
                }
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/cookie.svg"
                    width: 56; height: 56; fillMode: Image.PreserveAspectFit
                    scale: installing ? 1.0 : (1.0 + 0.03 * Math.sin(Date.now() / 400))
                    Behavior on scale { NumberAnimation { duration: 200 } }
                }

                // 版本角标
                Rectangle {
                    anchors.right: parent.right; anchors.bottom: parent.bottom
                    anchors.rightMargin: -2; anchors.bottomMargin: -2
                    width: versionLabel.implicitWidth + 12; height: 22; radius: 11
                    color: "#1f6feb"
                    visible: installing
                    Text {
                        id: versionLabel
                        anchors.centerIn: parent
                        text: "v" + updaterWin.version
                        color: "#fff"; font.pixelSize: 12; font.weight: Font.DemiBold
                        font.family: "JetBrains Mono"
                    }
                }
            }

            // ── 标题 ──
            Text {
                Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 8
                text: installing ? "正在安装更新" : "发现新版本"
                color: "#e6edf3"; font.pixelSize: 22; font.weight: Font.Bold
                font.family: "Microsoft YaHei UI"
                // letterSpacing: 1
            }

            Text {
                Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 30
                text: installing
                    ? "更新完成后 Surety 将自动重新启动"
                    : "正在从服务器获取 v" + updaterWin.version
                color: "#8b949e"; font.pixelSize: 15
                font.family: "Microsoft YaHei UI"
            }

            // ── 进度条 ──
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 8
                Layout.bottomMargin: 22; radius: 4
                color: "#21262d"
                Rectangle {
                    height: 8; radius: 4
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1f6feb" }
                        GradientStop { position: 1.0; color: "#58a6ff" }
                    }
                    width: parent.width * updaterWin.progress / 100
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }

            // ── 状态文字 ──
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                // 脉冲点
                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: installing ? "#3fb950" : "#1f6feb"
                    opacity: 0.6 + 0.4 * Math.sin(Date.now() / 600)
                }

                Text {
                    text: installing
                        ? "准备就绪"
                        : (updaterWin.progress > 0 ? updaterWin.progress + "%" : "正在连接...")
                    color: "#8b949e"; font.pixelSize: 14
                    font.family: "JetBrains Mono"
                }

                Text {
                    visible: updaterWin.progress > 0 && !installing
                    text: " — " + formatSize(updaterWin.progress)
                    color: "#484f58"; font.pixelSize: 12
                    font.family: "JetBrains Mono"
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ── 初始连接阶段假进度（用户不会感觉卡死） ──
    Timer {
        id: fakeTimer
        interval: 120; running: !installing && fakeProgress < 15; repeat: true
        property int fakeProgress: 0
        onTriggered: {
            fakeProgress += 1
            if (updaterWin.progress < fakeProgress)
                updaterWin.progress = fakeProgress
        }
    }
    Connections {
        target: updaterWin
        function onProgressChanged() {
            if (updaterWin.progress > 0) fakeTimer.running = false
        }
    }

    // ── 辅助函数 ──
    function formatSize(pct) {
        // 假计算：按总大小约 15MB 估算
        var mb = (15 * pct / 100).toFixed(1)
        return mb + " MB"
    }

    // ── 进出动画 ──
    Component.onCompleted: {
        updaterWin.scale = 0.85; updaterWin.opacity = 0
        scaleAnim.restart(); fadeIn.restart()
    }

    NumberAnimation { id: scaleAnim; target: updaterWin; property: "scale"
        from: 0.85; to: 1.0; duration: 400; easing.type: Easing.OutBack }
    NumberAnimation { id: fadeIn; target: updaterWin; property: "opacity"
        from: 0; to: 1.0; duration: 250 }

    Behavior on opacity {
        NumberAnimation { id: fadeOut; duration: 300; easing.type: Easing.InCubic }
    }
    // Behavior on scale {
    //     NumberAnimation { duration: 300; easing.type: Easing.InBack }
    // }
}
