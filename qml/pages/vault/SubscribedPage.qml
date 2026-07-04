import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"
import Surety 1.0

// 订阅资产页 — 列表 + 只读详情（.surety 加密）
Rectangle {
    id: page
    color: "transparent"

    property int selectedIndex: -1

    function getAsset(i) {
        if (!SubModel || i < 0 || i >= SubModel.count) return null
        return SubModel.get(i)
    }

    Connections {
        target: SubModel
        function onCountChanged() {
            if (SubModel.count > 0 && selectedIndex < 0)
                page.selectedIndex = 0
        }
    }

    RowLayout {
        anchors.fill: parent; spacing: 0

        // ── 左侧列表（仅订阅项）──
        Rectangle {
            Layout.preferredWidth: parent.width * 3 / 10
            Layout.fillHeight: true
            color: Theme.bg_input; radius: 12
            border.color: Theme.border_default; border.width: 1

            ListView {
                id: listView
                anchors.fill: parent; anchors.margins: 8
                clip: true; spacing: 6
                model: SubModel

                delegate: AssetListDelegate {
                    delegateWidth: listView.width - 16
                    delegateIndex: index; delegateName: model.name
                    delegateType: model.type; delegateColor: model.code
                    delegateVersion: model.version
                    delegateSelected: page.selectedIndex === index
                    hasSubscription: true
                    visible: model.hasSubscription
                    height: visible ? 64 : 0
                    onClicked: page.selectedIndex = (page.selectedIndex === index) ? -1 : index
                }
                ScrollBar.vertical: SuretyScrollBar {}
            }
        }

        // ── 右侧只读详情 ──
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.leftMargin: 20
            color: "transparent"

            AssetDetailPanel {
                id: detail
                anchors.fill: parent
                isReadOnly: true
            }
        }
    }

    onSelectedIndexChanged: {
        if (selectedIndex < 0) {
            detail.titleText = "---"
            detail.nameText = ""; detail.versionText = ""; detail.descText = ""; detail.typeIndex = 0
            detail.oncePrice = ""; detail.subPrice = ""; detail.subDuration = ""
            return
        }
        var item = page.getAsset(selectedIndex)
        if (!item) return
        detail.load(item)
    }
}
