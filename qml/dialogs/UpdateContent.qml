import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../themes"

Rectangle {
    id: root
    signal dismissClicked()

    property string currentVer: "1.0.0"
    property string latestVer: "1.0.0"
    property string releaseNotes: ""
    property string githubUrl: "https://github.com/SoloHomie/Surety/releases/latest"
    property string mirrorUrl: "https://ghproxy.com/https://github.com/SoloHomie/Surety/releases/latest"
    property bool forceUpdate: false

    implicitWidth: 650
    implicitHeight: 820
    width: implicitWidth
    height: implicitHeight
    color: Theme.bg_card
    radius: 16
    border.width: 1
    border.color: Theme.border_standard
    clip: true

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true; shadowColor: Theme.shadow_color
        shadowOpacity: 0.5; shadowBlur: 30
        shadowHorizontalOffset: 0; shadowVerticalOffset: 8
    }

    Rectangle {
        id: bannerArea
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top; height: 120
        color: Theme.bg_page
        topLeftRadius: root.radius
        topRightRadius: root.radius
        border.width: 1
        border.color: Theme.border_standard
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

        Text { visible: root.forceUpdate; Layout.fillWidth: true; Layout.bottomMargin: 8
            text: "⚠ " + qsTr("此版本必须更新，升级后才能继续使用")
            color: Theme.danger_fg; font.pixelSize: 17; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI" }
        Text { Layout.fillWidth: true; Layout.bottomMargin: 6
            text: qsTr("发现新版本")
            color: Theme.text_primary; font.pixelSize: 30; font.weight: Font.Bold
            font.family: "Microsoft YaHei UI"
        }
        Text {
            Layout.fillWidth: true; Layout.bottomMargin: 28
            text: "Surety v" + root.latestVer + " " + qsTr("已发布，建议更新以获取最新功能。")
            color: Theme.text_secondary; font.pixelSize: 17
            font.family: "Microsoft YaHei UI"
        }

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 90
            Layout.bottomMargin: 28; radius: 12; color: Theme.bg_input
            border.width: 1; border.color: Theme.border_default
            RowLayout {
                anchors.centerIn: parent; spacing: 0
                ColumnLayout {
                    Layout.preferredWidth: 210; spacing: 6
                    Text { Layout.alignment: Qt.AlignHCenter; text: qsTr("当前版本"); color: Theme.text_secondary; font.pixelSize: 16; font.family: "Microsoft YaHei UI" }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "" + root.currentVer; color: Theme.text_primary; font.pixelSize: 26; font.weight: Font.Bold; font.family: "JetBrains Mono" }
                }
                Text { text: "→"; color: Theme.accent; font.pixelSize: 30; font.weight: Font.Bold; font.family: "Microsoft YaHei UI"; Layout.leftMargin: 28; Layout.rightMargin: 28 }
                ColumnLayout {
                    Layout.preferredWidth: 210; spacing: 6
                    Text { Layout.alignment: Qt.AlignHCenter; text: qsTr("最新版本"); color: Theme.text_secondary; font.pixelSize: 16; font.family: "Microsoft YaHei UI" }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "" + root.latestVer; color: Theme.text_primary; font.pixelSize: 26; font.weight: Font.Bold; font.family: "JetBrains Mono" }
                }
            }
        }

        Text {
            Layout.fillWidth: true; Layout.bottomMargin: 10
            text: qsTr("更新内容")
            color: Theme.text_primary; font.pixelSize: 19; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            Layout.bottomMargin: 24; radius: 10; color: Theme.bg_input
            border.width: 1; border.color: Theme.border_default
            Flickable {
                anchors.fill: parent; anchors.margins: 18
                contentHeight: releaseText.implicitHeight; clip: true
                Text {
                    id: releaseText; width: parent.width
                    color: Theme.text_secondary; font.pixelSize: 16; lineHeight: 1.8
                    font.family: "Microsoft YaHei UI"; wrapMode: Text.WordWrap
                    text: root.releaseNotes !== "" ? root.releaseNotes : qsTr("• 性能优化与稳定性改进\n• 修复若干已知问题")
                }
            }
        }

        Text {
            Layout.fillWidth: true; Layout.bottomMargin: 12
            text: qsTr("下载方式")
            color: Theme.text_primary; font.pixelSize: 16; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI"
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 12

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 52
                radius: 10
                color: ghMa.containsMouse ? Theme.hover_bg : Theme.bg_page
                border.width: 1
                border.color: ghMa.containsMouse ? Theme.border_standard : Theme.border_default

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text { anchors.centerIn: parent; text: "GitHub"; color: Theme.text_primary; font.pixelSize: 17; font.family: "JetBrains Mono" }
                MouseArea { id: ghMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally(root.githubUrl) }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 52
                radius: 10
                color: mirrorMa.containsMouse ? Theme.hover_bg : Theme.bg_page
                border.width: 1
                border.color: mirrorMa.containsMouse ? Theme.border_standard : Theme.border_default

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text { anchors.centerIn: parent; text: "Proxy"; color: Theme.text_primary; font.pixelSize: 17; font.family: "Microsoft YaHei UI" }
                MouseArea { id: mirrorMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally(root.mirrorUrl) }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 52
                radius: 10
                color: serviceMa.containsMouse ? Theme.hover_bg : Theme.bg_page
                border.width: 1
                border.color: serviceMa.containsMouse ? Theme.border_standard : Theme.border_default

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text { anchors.centerIn: parent; text: "Discord"; color: Theme.text_primary; font.pixelSize: 17; font.family: "Microsoft YaHei UI" }
                MouseArea { id: serviceMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Qt.openUrlExternally(root.mirrorUrl) }
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 12 }

        Rectangle {
            visible: !root.forceUpdate
            Layout.fillWidth: true; Layout.preferredHeight: 48
            radius: 10
            color: closeMa.containsMouse ? Theme.border_default : "transparent"
            border.width: 1; border.color: Theme.border_default
            Behavior on color { ColorAnimation { duration: 150 } }

            Text { anchors.centerIn: parent; text: qsTr("稍后提醒"); color: Theme.text_secondary; font.pixelSize: 17; font.family: "Microsoft YaHei UI" }
            MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.dismissClicked() }
        }
    }
}
