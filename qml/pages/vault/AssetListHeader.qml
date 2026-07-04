import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

// 资产列表头部 — 个人/订阅切换 + 管理按钮
RowLayout {
    id: root
    height: 48

    property alias tabIndex: tabSelector.selectedIndex
    signal tabChanged(int index)
    signal manageClicked()

    SuretyTagSelector {
        id: tabSelector
        displayMode: "segment"
        segmentHeight: 40
        segmentRadius: 8
        fontSize: 14
        minimumWidth: 160
        model: tabModel
        onTagSelected: function(idx) { root.tabChanged(idx) }
    }

    property var tabModel: [
        { label: qsTr("个人") },
        { label: qsTr("订阅") },
        { label: qsTr("本地") }
    ]

    Connections {
        target: Lang
        function onLanguageChanged() { tabModel = [
            { label: qsTr("个人") },
            { label: qsTr("订阅") },
            { label: qsTr("本地") }
        ]}
    }

    Item { Layout.fillWidth: true }

    Item {
        id: manageBtn
        Layout.preferredWidth: 36; Layout.preferredHeight: 36

        Image {
            anchors.centerIn: parent
            source: "qrc:/qml/images/组管理.svg"
            width: 22; height: 22
            opacity: manageMouse.containsMouse ? 1.0 : 0.65
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        MouseArea {
            id: manageMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.manageClicked()
        }
    }
}
