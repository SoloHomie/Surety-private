import QtQuick
import QtQuick.Controls
import "../../baseComponents"

Rectangle {
    id: heatRanking
    color: "#161b22"
    radius: 12
    border.width: 1
    border.color: "#30363d"
    clip: true

    signal itemClicked(string name, string type, string callCount)

    // 入场：缩放+淡入
    scale: 0.95
    opacity: 0

    Component.onCompleted: {
        scale = 1.0
        opacity = 1.0
    }

    Behavior on scale   { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    // ── 标题栏 ──
    Text {
        id: titleText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 16
        height: 24
        text: qsTr("Heat Ranking")
        color: "#e6edf3"
        font.pixelSize: 18
        font.weight: Font.DemiBold
        font.family: "JetBrains Mono"
        verticalAlignment: Text.AlignVCenter
    }

    // ── 分割线 ──
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleText.bottom
        anchors.topMargin: 16
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        height: 1
        color: "#30363d"
    }

    // ── 排行列表 ──
    ListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleText.bottom
        anchors.topMargin: 34
        anchors.bottom: parent.bottom
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 8
        clip: true
        spacing: 2

        model: ListModel {
            ListElement { rank: 1; icon: ""; name: "半导体图谱 Q1";      type: "知识包"; call: "2,340 次" }
            ListElement { rank: 2; icon: ""; name: "竞品分析脚本 v2.3";   type: "脚本";   call: "1,890 次" }
            ListElement { rank: 3; icon: ""; name: "供应链探针 Agent";    type: "工具";   call: "1,560 次" }
            ListElement { rank: 4; icon: ""; name: "晶圆良率预测模型";    type: "模型";   call: "1,230 次" }
            ListElement { rank: 5; icon: ""; name: "射频仿真工作流";      type: "工作流";  call: "980 次"  }
            ListElement { rank: 6; icon: ""; name: "GaN 技术知识库";      type: "知识包"; call: "760 次"  }
            ListElement { rank: 7; icon: ""; name: "先进封装工艺流程";     type: "脚本";   call: "640 次"  }
            ListElement { rank: 8; icon: ""; name: "专利地图分析工具";    type: "工具";   call: "520 次"  }
        }

        delegate: RankingDelegate {
            width: listView.width
            rank: model.rank
            assetIcon: model.icon
            assetName: model.name
            assetType: model.type
            callCount: model.call

            onNameClicked: heatRanking.itemClicked(model.name, model.type, model.call)
        }

        ScrollBar.vertical: SuretyScrollBar { }

        // 列表项错峰入场
        add: Transition {
            SequentialAnimation {
                PauseAnimation { duration: Math.min(index * 40, 250) }
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "x"; from: -12; to: 0; duration: 260; easing.type: Easing.OutBack }
                }
            }
        }

        displaced: Transition {
            NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutCubic }
        }
    }
}
