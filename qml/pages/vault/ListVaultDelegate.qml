import QtQuick
import "../../baseComponents"

Rectangle {
    id: root
    // 运行时跟随 ListView 宽度，设计时回退到 380 便于 Qt DS 预览
    width: ListView.view ? ListView.view.width : 380

    height: 46
    radius: 4
    color: "transparent"

    // 默认示例值仅用于 Qt Design Studio 预览，实际会被父组件覆盖
    property string assetName:  "半导体图谱 Q1"
    property string assetType:  "知识包"
    property string assetIcon:  "K"
    property color  assetColor: "#C89B3C"
    property bool   quickSale:  true

    signal clicked()
    signal saleToggled(bool on)

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    // 图标
    Rectangle {
        id: iconBox
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 28; height: 28
        radius: 5
        color: root.assetColor

        Text {
            anchors.centerIn: parent
            text: root.assetIcon
            color: "#0d1117"
            font.pixelSize: 16
            font.weight: Font.Bold
            font.family: "JetBrains Mono"
        }
    }

    // 名称
    Text {
        id: nameText
        anchors.left: iconBox.right
        anchors.leftMargin: 10
        anchors.right: toggleSwitch.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.assetName
        color: "#e6edf3"
        font.pixelSize: 16
        font.weight: Font.Medium
        font.family: "Microsoft YaHei UI"
        elide: Text.ElideRight
    }

    // 开关
    SuretySwitch {
        id: toggleSwitch
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 44; height: 24
        checked: root.quickSale
        onToggled: (on) => root.saleToggled(on)
    }
}
