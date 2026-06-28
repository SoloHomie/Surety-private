import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "../../baseComponents"

Item {
    id: root

    Connections {
        target: Api
        function onUpdateCheckFinished(info) {
            if (info && info.hasUpdate) {
                updateBadge.visible = true
                updateBadgeText.text = "v" + info.latestVer + " 可用"
                root._downloadUrl = info.githubUrl || ""
            }
        }
    }

    property string _downloadUrl: ""

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Image {
            source: "qrc:/qml/images/cookie.svg"
            width: 80; height: 80
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
            fillMode: Image.PreserveAspectFit
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
            text: "Surety"
            color: "#e6edf3"
            font.pixelSize: 28
            font.weight: Font.Bold
            font.family: "Microsoft YaHei UI"
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 18
            spacing: 8

            Text {
                text: "版本 1.0.0"
                color: "#6e7681"
                font.pixelSize: 16
                font.family: "JetBrains Mono"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: Qt.openUrlExternally("https://github.com/SoloHomie/Surety")
                }
            }

            Rectangle {
                id: updateBadge
                visible: false
                radius: 4; height: 22
                width: updateBadgeText.implicitWidth + 14
                color: "#1a2332"
                border.color: "#1f6feb"
                border.width: 1

                Text {
                    id: updateBadgeText
                    anchors.centerIn: parent
                    color: "#58a6ff"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    font.family: "Microsoft YaHei UI"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (root._downloadUrl !== "")
                            Qt.openUrlExternally(root._downloadUrl)
                    }
                }
            }
        }

        SuretyBtn {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 28
            Layout.preferredHeight: 36
            text: "检查更新"
            variant: "outline"
            font.pixelSize: 15
            font.family: "Microsoft YaHei UI"
            onClicked: Api.checkUpdate()
        }

        Rectangle {
            Layout.preferredWidth: 300
            Layout.preferredHeight: 1
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 28
            color: "#21262d"
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 36
            spacing: 12

            RowLayout {
                spacing: 32
                Text { Layout.preferredWidth: 64; text: "开发者"; color: "#8b949e"; font.pixelSize: 15; font.family: "Microsoft YaHei UI" }
                Text { text: "Homie"; color: "#e6edf3"; font.pixelSize: 15; font.family: "Microsoft YaHei UI" }
            }
        }

        Item { Layout.preferredHeight: 1 }
    }
}
