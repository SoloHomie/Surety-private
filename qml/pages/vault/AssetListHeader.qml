import QtQuick
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
        model: [
            { label: "个人" },
            { label: "订阅" }
        ]
        onTagSelected: function(idx) { root.tabChanged(idx) }
    }

    Item { Layout.fillWidth: true }

    Button {
        id: manageBtn
        rightPadding: 0; leftPadding: 0
        bottomPadding: 0; topPadding: 0
        Layout.preferredWidth: 36; Layout.preferredHeight: 36
        flat: true

        icon.source: "qrc:/qml/images/组管理.svg"
        icon.width: 20; icon.height: 20
        icon.color: hovered ? "#e6edf3" : "#8b949e"

        background: Rectangle {
            anchors.fill: parent; radius: 6
            color: manageBtn.hovered ? "#21262d" : "transparent"
        }
        onClicked: root.manageClicked()
    }
}
