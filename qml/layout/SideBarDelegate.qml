import QtQuick
import "../themes"

Rectangle {
    id: root
    width: 180
    height: 44
    radius: 8

    property string iconImage: ""
    property string sideText:  ""
    property bool   isSelected: false

    signal clicked()

    // 背景: 10% 蓝色 hover, 透明默认
    color: {
        if (isSelected)              return Qt.rgba(0.12, 0.44, 0.92, 0.15)
        if (mouseArea.containsMouse) return Qt.rgba(0.12, 0.44, 0.92, 0.10)
        return "transparent"
    }

    // 选中蓝色边框
    border.width: isSelected ? 1 : 0
    border.color: isSelected ? Qt.rgba(0.12, 0.44, 0.92, 0.50) : "transparent"

    Behavior on color       { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.OutCubic } }

    // 选中左指示条
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 0
        width: 3; height: 18
        radius: 2
        color: isSelected ? "#1f6feb" : "transparent"
        visible: isSelected
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        height: 28
        spacing: 12

        // 图标
        Image {
            id: iconImg
            width: 28; height: 28
            anchors.verticalCenter: parent.verticalCenter
            source: iconImage
            sourceSize.width: 56
            sourceSize.height: 56
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: {
                if (isSelected)              return 1.0
                if (mouseArea.containsMouse) return 0.85
                return 0.50
            }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // 文字
        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: sideText
            color: {
                if (isSelected)              return "#e6edf3"
                if (mouseArea.containsMouse) return "#c9d1d9"
                return "#8b949e"
            }
            font.pixelSize: 24
            font.weight: Font.Light
            font.family: "Microsoft YaHei UI"

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    // 交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
