import QtQuick
import "../../themes"
import QtQuick.Controls
import "../../baseComponents"

Rectangle {
    id: heatRanking
    color: Theme.bg_card
    radius: 12
    border.width: 1
    border.color: Theme.border_standard
    clip: true

    signal itemClicked(var listing)

    property var rankings: []

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
        text: qsTr("热度榜")
        color: Theme.text_primary
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
        color: Theme.border_standard
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

        model: heatRanking.rankings

        delegate: RankingDelegate {
            width: listView.width
            rank: index + 1
            assetIcon: ""
            assetName: modelData.name || ""
            assetType: modelData.type || ""
            callCount: (modelData.subCount || 0) + " " + qsTr("次订阅")

            onNameClicked: heatRanking.itemClicked(modelData)
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
