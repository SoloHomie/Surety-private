import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.topMargin: 28; Layout.bottomMargin: 20

    signal providerClicked(string name)

    // OR 分割线
    RowLayout {
        Layout.fillWidth: true; spacing: 0
        Rectangle { Layout.fillWidth: true; height: 1; color: "#21262d" }
        //Text { text: "OR"; color: "#484f58"; font.pixelSize: 13; font.family: "JetBrains Mono" }
        Rectangle { Layout.fillWidth: true; height: 1; color: "#21262d" }
    }

    Item { Layout.preferredHeight: 20 }

    // 第三方登录图标
    RowLayout {
        Layout.fillWidth: true; spacing: 14
        Item { Layout.fillWidth: true }
        Repeater {
            model: [
                { name: "微信",   icon: "qrc:/qml/images/微信.svg",   color: "#07C160", hoverBg: "#1a2e1f" },
                { name: "GitHub", icon: "qrc:/qml/images/github.svg", color: "#f0f6fc", hoverBg: "#1c2128" },
                { name: "QQ",     icon: "qrc:/qml/images/QQ.svg",     color: "#12B7F5", hoverBg: "#1a2a33" },
                { name: "Discord",icon: "qrc:/qml/images/discord.svg",color: "#5865F2", hoverBg: "#1a1e33" },
            ]
            Rectangle {
                Layout.preferredWidth: 60; Layout.preferredHeight: 60; radius: 12
                color: _hover.containsMouse ? modelData.hoverBg : "#161b22"
                border.width: 1
                border.color: _hover.containsMouse ? modelData.color : "#30363d"
                Behavior on color        { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                MouseArea {
                    id: _hover
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.providerClicked(modelData.name)
                }
                Image {
                    anchors.centerIn: parent; width: 32; height: 32
                    source: modelData.icon
                    sourceSize.width: 64; sourceSize.height: 64
                    fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true
                }
            }
        }
        Item { Layout.fillWidth: true }
    }

    Item { Layout.preferredHeight: 24 }
}
