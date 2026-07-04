import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "../../baseComponents"

// 资产管理抽屉 — 仅个人资产（非订阅），可快速上下架
Drawer {
    id: root
    edge: Qt.RightEdge
    width: 420
    modal: false
    interactive: true

    property real parentHeight: 936
    property var  model: null

    height: parentHeight + 64

    background: Rectangle {
        color: Theme.bg_card
        border.color: Theme.border_default
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Text {
            text: qsTr("快速管理")
            color: Theme.text_primary
            font.pixelSize: 20
            font.weight: Font.Bold
            font.family: "Microsoft YaHei UI"
        }

        ListView {
            id: quickListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            focusPolicy: Qt.NoFocus
            model: root.model

            delegate: ListVaultDelegate {
                width:  quickListView.width
                visible: !model.hasSubscription
                height:  visible ? 56 : 0

                assetName:  model.name
                assetType:  model.type
                assetIcon:  model.name.charAt(0)
                assetColor: model.code
                quickSale:  model.quick !== undefined ? model.quick : false

                onSaleToggled: function(on) {
                    if (on) Api.quickListAsset(model.assetId)
                    else    Api.quickUnlistAsset(model.assetId)
                }
            }

            ScrollBar.vertical: SuretyScrollBar { }
        }
    }
}
