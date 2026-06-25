import QtQuick

Rectangle {
    id: root
    width: ListView.view ? ListView.view.width : 344
    height: 46
    radius: 4
    color: "transparent"

    property int    rank:       0
    property string assetIcon:  ""
    property string assetName:  ""
    property string assetType:  ""
    property string callCount:  ""

    signal clicked()
    signal nameClicked()

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    // 排名
    Text {
        id: rankText
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        text: root.rank
        font.pixelSize: 20
        font.weight: Font.Bold
        font.family: "JetBrains Mono"
        horizontalAlignment: Text.AlignHCenter
        color: {
            if (root.rank === 1) return "#C89B3C"
            if (root.rank === 2) return "#8b949e"
            if (root.rank === 3) return "#c6905b"
            return "#484f58"
        }
    }

    // 调用次数 (右侧固定，先锚定以计算剩余空间)
    Text {
        id: callText
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: root.callCount
        color: "#8b949e"
        font.pixelSize: 16
        font.family: "JetBrains Mono"
    }

    // 类型徽章
    Rectangle {
        id: typeBadge
        anchors.right: callText.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: typeLabel.implicitWidth + 14
        height: 20
        radius: 3

        readonly property string _t: root.assetType
        color: {
            if (_t === "知识包") return "#C89B3C"
            if (_t === "脚本")   return "#34D399"
            if (_t === "模型")   return "#58A6FF"
            if (_t === "工具")   return "#A371F7"
            if (_t === "工作流") return "#F59E0B"
            return "#484f58"
        }

        Text {
            id: typeLabel
            anchors.centerIn: parent
            text: root.assetType
            color: "#0d1117"
            font.pixelSize: 14
            font.weight: Font.Bold
            font.family: "JetBrains Mono"
        }
    }

    // 名称 (填充中间剩余空间，hover 高亮)
    Text {
        id: nameText
        anchors.left: rankText.right
        anchors.leftMargin: 14
        anchors.right: typeBadge.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.assetName
        color: nameMouse.containsMouse ? "#58a6ff" : "#e6edf3"
        font.pixelSize: 18
        font.underline: false
        font.family: "Microsoft YaHei UI"
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter

        Behavior on color { ColorAnimation { duration: 120 } }

        MouseArea {
            id: nameMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.nameClicked()
        }
    }
}
