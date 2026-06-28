import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    signal dismissClicked()

    property string currentVer: "1.0.0"
    property string latestVer: "1.1.0"
    property string releaseNotes: ""
    property string githubUrl: "https://github.com/SoloHomie/Surety/releases/latest"
    property string mirrorUrl: "https://ghproxy.com/https://github.com/SoloHomie/Surety/releases/latest"

    implicitWidth: 650
    implicitHeight: 820
    width: implicitWidth
    height: implicitHeight
    color: "#161b22"
    radius: 16
    border.width: 1
    border.color: "#30363d"
    clip: true

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true; shadowColor: "#000000"
        shadowOpacity: 0.5; shadowBlur: 30
        shadowHorizontalOffset: 0; shadowVerticalOffset: 8
    }

    Rectangle {
        id: bannerArea
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top; height: 120
        color: "#0d1117"
        topLeftRadius: root.radius
        topRightRadius: root.radius
        border.width: 1
        border.color: "#30363d"
        Image {
            anchors.centerIn: parent
            width: 80; height: 80
            source: "qrc:/qml/images/cookie.svg"
            fillMode: Image.PreserveAspectFit
        }
    }

    ColumnLayout {
        id: updateColumn
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: bannerArea.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 36; spacing: 0

        Text {
            Layout.fillWidth: true; Layout.bottomMargin: 6
            text: "发现新版本"
            color: "#e6edf3"; font.pixelSize: 30; font.weight: Font.Bold
            font.family: "Microsoft YaHei UI"
        }
        Text {
            Layout.fillWidth: true; Layout.bottomMargin: 28
            text: "Surety v" + root.latestVer + " 已发布，建议更新以获取最新功能。"
            color: "#8b949e"; font.pixelSize: 17
            font.family: "Microsoft YaHei UI"
        }

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 90
            Layout.bottomMargin: 28; radius: 12; color: "#010409"
            RowLayout {
                anchors.centerIn: parent; spacing: 0
                ColumnLayout {
                    Layout.preferredWidth: 210; spacing: 6
                    Text { Layout.alignment: Qt.AlignHCenter; text: "当前版本"; color: "#8b949e"; font.pixelSize: 16; font.family: "Microsoft YaHei UI" }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "v" + root.currentVer; color: "#e6edf3"; font.pixelSize: 26; font.weight: Font.Bold; font.family: "JetBrains Mono" }
                }
                Text { text: "→"; color: "#58a6ff"; font.pixelSize: 30; font.weight: Font.Bold; font.family: "Microsoft YaHei UI"; Layout.leftMargin: 28; Layout.rightMargin: 28 }
                ColumnLayout {
                    Layout.preferredWidth: 210; spacing: 6
                    Text { Layout.alignment: Qt.AlignHCenter; text: "最新版本"; color: "#8b949e"; font.pixelSize: 16; font.family: "Microsoft YaHei UI" }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "v" + root.latestVer; color: "#3fb950"; font.pixelSize: 26; font.weight: Font.Bold; font.family: "JetBrains Mono" }
                }
            }
        }

        Text {
            Layout.fillWidth: true; Layout.bottomMargin: 10
            text: "更新内容"
            color: "#e6edf3"; font.pixelSize: 19; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            Layout.bottomMargin: 24; radius: 10; color: "#010409"
            Flickable {
                anchors.fill: parent; anchors.margins: 18
                contentHeight: releaseText.implicitHeight; clip: true
                Text {
                    id: releaseText; width: parent.width
                    color: "#8b949e"; font.pixelSize: 16; lineHeight: 1.8
                    font.family: "Microsoft YaHei UI"; wrapMode: Text.WordWrap
                    text: root.releaseNotes !== "" ? root.releaseNotes : "• 性能优化与稳定性改进\n• 修复若干已知问题"
                }
            }
        }

        Text {
            Layout.fillWidth: true; Layout.bottomMargin: 12
            text: "下载方式"
            color: "#e6edf3"; font.pixelSize: 16; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI"
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 12

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 52
                radius: 10
                color: ghMa.containsMouse ? "#1f6feb" : "#010409"
                border.width: 1
                border.color: ghMa.containsMouse ? "#388bfd" : "#30363d"

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text { anchors.centerIn: parent; text: "GitHub"; color: ghMa.containsMouse ? "#ffffff" : "#e6edf3"; font.pixelSize: 15; font.family: "JetBrains Mono" }
                MouseArea { id: ghMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally(root.githubUrl) }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 52
                radius: 10
                color: mirrorMa.containsMouse ? "#1f6feb" : "#010409"
                border.width: 1
                border.color: mirrorMa.containsMouse ? "#388bfd" : "#30363d"

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text { anchors.centerIn: parent; text: "镜像加速"; color: mirrorMa.containsMouse ? "#ffffff" : "#e6edf3"; font.pixelSize: 15; font.family: "Microsoft YaHei UI" }
                MouseArea { id: mirrorMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally(root.mirrorUrl) }
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 12 }

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 48
            radius: 10
            color: closeMa.containsMouse ? "#21262d" : "transparent"
            border.width: 1; border.color: "#21262d"
            Behavior on color { ColorAnimation { duration: 150 } }

            Text { anchors.centerIn: parent; text: "稍后提醒"; color: "#8b949e"; font.pixelSize: 17; font.family: "Microsoft YaHei UI" }
            MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.dismissClicked() }
        }
    }
}
