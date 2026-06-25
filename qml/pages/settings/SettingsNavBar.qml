import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 设置页导航栏 — tab 风格路由切换
Rectangle {
    id: root
    height: 72
    color: "#0d1117"
    radius: 10
    border.color: "#21262d"
    border.width: 1

    property string currentPage: "general"

    signal pageChanged(string page)

    // 入场：顶部滑入
    y: -12
    opacity: 0

    Component.onCompleted: {
        y = 0
        opacity = 1
    }

    Behavior on y       { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 8
        spacing: 4

        Text {
            text: "设置"
            color: "#e6edf3"
            font.pixelSize: 28
            font.weight: Font.Bold
            font.family: "Microsoft YaHei UI"
            Layout.rightMargin: 28
        }

        Repeater {
            model: ListModel {
                ListElement { label: "常规"; page: "general"    }
                ListElement { label: "外观"; page: "appearance" }
                ListElement { label: "高级"; page: "advanced"   }
                ListElement { label: "关于"; page: "about"      }
                ListElement { label: "Beta";  page: "beta"      }
            }

            Rectangle {
                id: navItem
                width: navLabel.implicitWidth + 36
                height: 44
                radius: 10
                Layout.alignment: Qt.AlignVCenter

                readonly property bool _sel: root.currentPage === model.page
                readonly property bool _hov: navMouse.containsMouse

                color: {
                    if (_sel) return "#1f6feb"
                    if (_hov) return "#161b22"
                    return "transparent"
                }

                // 选中/悬停背景渐变
                Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.OutCubic } }

                // 点击缩放反馈
                scale: navMouse.pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                // 底部指示条
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 2
                    width: _sel ? 24 : 0
                    height: 3
                    radius: 2
                    color: _sel ? "#ffffff" : "transparent"

                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                    id: navLabel
                    anchors.centerIn: parent
                    text: model.label
                    color: {
                        if (_sel) return "#ffffff"
                        if (_hov) return "#c9d1d9"
                        return "#8b949e"
                    }
                    font.pixelSize: 18
                    font.weight: _sel ? Font.Bold : Font.Normal
                    font.family: "Microsoft YaHei UI"
                    scale: _sel ? 1.05 : 1.0

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                }

                MouseArea {
                    id: navMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pageChanged(model.page)
                }
            }
        }

        Item { Layout.fillWidth: true }
    }
}
