import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sideBar
    width: 220
    height: 1000
    color: "#010409"
    bottomLeftRadius: 10
    topLeftRadius: 10

    property int selectedIndex: 0

    signal pageSwitchRequested(int index)

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 20
        anchors.bottomMargin: 0
        uniformCellSizes: false
        spacing: 8

        Repeater {
            model: ListModel {
                ListElement { icon: "qrc:/qml/images/home_icon.svg";  text: "主页" }
                ListElement { icon: "qrc:/qml/images/资产.svg";       text: "资产" }
                ListElement { icon: "qrc:/qml/images/礼物.svg";       text: "市场" }
                ListElement { icon: "qrc:/qml/images/设置.svg";       text: "设置" }
            }
            delegate: SideBarDelegate {
                Layout.fillWidth: true
                iconImage: icon
                sideText: text
                isSelected: index === sideBar.selectedIndex
                onClicked: sideBar.pageSwitchRequested(index)
            }
        }

        Item { Layout.fillHeight: true }

    }

}
