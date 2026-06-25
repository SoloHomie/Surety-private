import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "../../baseComponents"

Item {
    id: root

    Connections {
        target: Api
        function onUpdateCheckFinished(hasUpdate, latest, url) {
            if (hasUpdate) {
                updateBadge.visible = true
                updateBadgeText.text = "v" + latest + " 可用"
                root._downloadUrl = url
            }
        }
    }

    property string _downloadUrl: ""

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        // ── Logo ──
        Rectangle {
            width: 72; height: 72; radius: 16
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
            color: "#1f6feb"
            Image {
                anchors.centerIn: parent
                source: "qrc:/qml/images/cookie.svg"
                width: 42; height: 42
                fillMode: Image.PreserveAspectFit
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
            text: "Surety"
            color: "#e6edf3"
            font.pixelSize: 24; font.weight: Font.Bold
            font.family: "Microsoft YaHei UI"
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 14
            spacing: 8

            Text {
                text: "版本 1.1.0"
                color: "#6e7681"
                font.pixelSize: 13
                font.family: "JetBrains Mono"
            }

            Rectangle {
                id: updateBadge
                visible: false
                radius: 4; height: 20
                width: updateBadgeText.implicitWidth + 12
                color: "#1a2332"
                border.color: "#1f6feb"

                Text {
                    id: updateBadgeText
                    anchors.centerIn: parent
                    color: "#58a6ff"
                    font.pixelSize: 11; font.weight: Font.Bold
                    font.family: "Microsoft YaHei UI"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root._downloadUrl !== "")
                            Qt.openUrlExternally(root._downloadUrl)
                    }
                }
            }
        }

        SuretyBtn {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 34
            Layout.bottomMargin: 20
            text: "检查更新"
            variant: "outline"
            font.pixelSize: 14
            font.family: "Microsoft YaHei UI"
            onClicked: Api.checkUpdate()
        }

        Rectangle {
            Layout.preferredWidth: 280; Layout.preferredHeight: 1
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
            color: "#21262d"
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 32
            spacing: 10

            RowLayout {
                spacing: 24
                Text { Layout.preferredWidth: 56; text: "开发者"; color: "#8b949e"; font.pixelSize: 13; font.family: "Microsoft YaHei UI" }
                Text { text: "Homie"; color: "#e6edf3"; font.pixelSize: 13; font.family: "Microsoft YaHei UI" }
            }
            RowLayout {
                spacing: 24
                Text { Layout.preferredWidth: 56; text: "技术栈"; color: "#8b949e"; font.pixelSize: 13; font.family: "Microsoft YaHei UI" }
                Text { text: "C++20 / Qt 6 / MySQL / Redis"; color: "#e6edf3"; font.pixelSize: 13; font.family: "JetBrains Mono" }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "© 2026 Homie"
            color: "#484f58"
            font.pixelSize: 11
            font.family: "Microsoft YaHei UI"
        }
    }
}
