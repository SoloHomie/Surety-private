import QtQuick
import "../../themes"
import QtQuick.Controls

Rectangle {
    id: quickRect
    color: Theme.bg_card
    radius: 12
    border.width: 1
    border.color: Theme.border_default

    Text {
        id: titleText
        text: qsTr("Quick Actions")
        color: Theme.text_secondary
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
            tooltip: qsTr("快速上架资产")
        }

        QuickActionsDelegate {
            isAddSlot: true
            iconSource: "qrc:/qml/images/add_icon.svg"
            iconSize: 18
            tooltip: "添加快捷功能"
        }
    }
}
