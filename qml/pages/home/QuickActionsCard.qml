import QtQuick
import QtQuick.Controls

Rectangle {
    id: quickRect
    color: "#161b22"
    radius: 12
    border.width: 1
    border.color: "#21262d"

    Text {
        id: titleText
        text: qsTr("Quick Actions")
        color: "#8b949e"
        font.pixelSize: 13; font.weight: Font.DemiBold
        font.family: "JetBrains Mono"
        anchors.left: parent.left;   anchors.leftMargin: 16
        anchors.top: parent.top;     anchors.topMargin: 14
    }

    Row {
        anchors.left: parent.left;   anchors.leftMargin: 12
        anchors.top: titleText.bottom; anchors.topMargin: 10
        spacing: 4

        QuickActionsDelegate {
            iconSource: "qrc:/qml/images/list_icon.svg"
            tooltip: "快速上架资产"
        }

        QuickActionsDelegate {
            isAddSlot: true
            iconSource: "qrc:/qml/images/add_icon.svg"
            iconSize: 18
            tooltip: "添加快捷功能"
        }
    }
}
