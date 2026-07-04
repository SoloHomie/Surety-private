import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"
import "../../toast"
import Surety 1.0
import "../../js/utils.js" as Utils

Rectangle {
    id: wallet
    color: "transparent"
    property string payMethod: "微信支付"
    property string amount: "100"

    property var txList: []
    property var rechargeList: []

    Component.onCompleted: { if (Api.isLoggedIn) { Api.fetchBalance(); Api.fetchTransactions() } }

    Connections {
        target: Api
        function onTransactionsReady(list) {
            wallet.txList = []
            wallet.rechargeList = []
            for (var i = 0; i < list.length; i++) {
                var t = list[i]
                if (t.type === "recharge" || t.type === "claim") wallet.rechargeList.push(t)
                else wallet.txList.push(t)
            }
            rechargeModel.clear()
            for (var j = 0; j < wallet.rechargeList.length; j++) {
                var r = wallet.rechargeList[j]
                rechargeModel.append({ m: r.type, a: Utils.formatAmount(r.amount), t: r.time })
            }
            tradeModel.clear()
            for (var k = 0; k < wallet.txList.length; k++) {
                var x = wallet.txList[k]
                tradeModel.append({ m: x.type, a: x.amount+" Surety", t: x.time })
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 24

        // ══ 左侧 ══
        Item {
            Layout.preferredWidth: 340
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                // 余额
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    radius: 18
                    color: "#0d1117"
                    border.width: 1
                    border.color: Theme.border_default

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#1a1f35" }
                            GradientStop { position: 1; color: Theme.bg_card }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Surety 余额")
                            color: Theme.text_secondary
                            font.pixelSize: 15
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Api.suretyBalance + " Surety"
                            color: Theme.text_bright
                            font.pixelSize: 44
                            font.weight: Font.Bold
                            font.family: "JetBrains Mono"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "≈ ¥" + Api.suretyBalance + ".00"
                            color: Theme.text_hint
                            font.pixelSize: 15
                            font.family: "JetBrains Mono"
                        }
                    }
                }

                SuretyBtn {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    text: qsTr("充值")
                    variant: "primary"
                    font: Qt.font({ pixelSize: 20, weight: Font.Bold })
                    onClicked: rechargeDialog.open()
                }

                Item { Layout.fillHeight: true }
            }
        }

        // ══ 右侧 ══
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: Theme.bg_card
            border.width: 1
            border.color: Theme.border_default

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                SuretyTagSelector {
                    id: tab
                    displayMode: "segment"; minimumWidth: 0
                    model: [{ label: qsTr("充值记录") }, { label: qsTr("交易记录") }]
                    selectedIndex: 0
                }

                Item { Layout.preferredWidth: 1; Layout.preferredHeight: 8 }

                // 表头
                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 28
                    Row {
                        anchors.fill: parent
                        Text { width: 100; text: qsTr("方式"); color: Theme.text_hint; font.pixelSize: 13 }
                        Text { width: 120; text: qsTr("金额"); color: Theme.text_hint; font.pixelSize: 13 }
                        Text { text: qsTr("时间"); color: Theme.text_hint; font.pixelSize: 13 }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.border_default }

                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true; visible: tab.selectedIndex === 0
                    clip: true; spacing: 2
                    model: ListModel { id: rechargeModel }
                    delegate: recordDelegate
                    ScrollBar.vertical: SuretyScrollBar {}
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true; visible: tab.selectedIndex === 1
                    clip: true; spacing: 2
                    model: ListModel { id: tradeModel }
                    delegate: recordDelegate
                    ScrollBar.vertical: SuretyScrollBar {}
                }
            }
        }
    }

    // ══ 记录行 ══
    Component {
        id: recordDelegate
        Rectangle {
            width: ListView.view.width
            height: 44
            radius: 6
            color: mouse.containsMouse ? Theme.hover_bg : "transparent"
            readonly property bool isIn: model.a.charAt(0) === "+"
            Row {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                Rectangle {
                    width: 70; height: 24; radius: 5
                    anchors.verticalCenter: parent.verticalCenter
                    color: isIn ? Qt.rgba(0.22, 0.65, 0.32, 0.12) : Qt.rgba(0.95, 0.30, 0.20, 0.12)
                    Text {
                        anchors.centerIn: parent
                        text: model.m
                        font.pixelSize: 12
                        color: isIn ? Theme.success_fg : Theme.danger_fg
                    }
                }
                Text {
                    width: 120
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 10
                    text: model.a
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                    color: isIn ? Theme.success_fg : Theme.danger_fg
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.t
                    color: Theme.text_hint
                    font.pixelSize: 12
                    font.family: "JetBrains Mono"
                }
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    // ══ 充值弹窗 ══
    Dialog {
        id: rechargeDialog
        width: 480; height: 660
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.CloseOnEscape
        padding: 32
        background: Rectangle {
            radius: 18
            color: Theme.bg_card
            border.width: 1
            border.color: Theme.border_standard
        }
        Overlay.modal: Rectangle { color: "#000000"; opacity: 0.65 }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 标题
            Item { Layout.fillWidth: true; Layout.preferredHeight: 36
                Text {
                    text: qsTr("充值中心")
                    color: Theme.text_primary
                    font.pixelSize: 22; font.weight: Font.Bold
                    font.family: "Microsoft YaHei UI"
                }
                SuretyBtn {
                    anchors.right: parent.right
                    text: "×"; variant: "default"
                    width: 34; height: 34; font.pixelSize: 18
                    onClicked: rechargeDialog.close()
                }
            }

            Item { Layout.preferredHeight: 16 }

            // 金额
            Row { Layout.fillWidth: true; spacing: 8
                Repeater {
                    model: ["50","100","200","500","1000"]
                    Rectangle {
                        width: (rechargeDialog.availableWidth - 32) / 5; height: 44; radius: 10
                        color: wallet.amount === modelData ? Theme.accent : Theme.bg_input
                        border.width: wallet.amount === modelData ? 2 : 1
                        border.color: wallet.amount === modelData ? Theme.accent : Theme.border_default
                        Text { anchors.centerIn: parent; text: modelData
                            color: wallet.amount === modelData ? Theme.text_bright : Theme.text_primary
                            font.pixelSize: 17; font.weight: Font.Bold; font.family: "JetBrains Mono" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: wallet.amount = modelData }
                    }
                }
            }

            Item { Layout.preferredHeight: 28 }

            // 二维码
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 220; height: 220; radius: 14; color: "#ffffff"
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "█▀▀▀█ █ █ █▀▀█\n█ ▀▀█ █▀█ █  █\n█▄▄▄█ ▀ ▀ █▄▄▀"
                        color: "#111"; font.pixelSize: 15; font.family: "JetBrains Mono"; lineHeight: 1.2
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("扫一扫支付")
                        color: "#888"; font.pixelSize: 12; font.family: "Microsoft YaHei UI"
                    }
                }
            }

            Item { Layout.preferredHeight: 16 }

            // 提示
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: wallet.payMethod + " " + qsTr("扫码支付")
                color: Theme.text_secondary
                font.pixelSize: 13
            }

            Item { Layout.preferredHeight: 24 }

            // 支付方式
            Row { Layout.fillWidth: true; spacing: 10
                Repeater {
                    model: [qsTr("微信支付"), qsTr("支付宝")]
                    Rectangle {
                        width: (rechargeDialog.availableWidth - 10) / 2; height: 46; radius: 10
                        color: wallet.payMethod === modelData ? Theme.selected_bg : Theme.bg_input
                        border.width: wallet.payMethod === modelData ? 2 : 1
                        border.color: wallet.payMethod === modelData ? Theme.accent : Theme.border_default
                        Text { anchors.centerIn: parent; text: modelData; color: Theme.text_primary
                            font.pixelSize: 14; font.family: "Microsoft YaHei UI" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: wallet.payMethod = modelData }
                    }
                }
            }

            Item { Layout.preferredHeight: 28 }

            // 金额总计
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 56; radius: 12; color: Theme.bg_input
                Column {
                    anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 18
                    spacing: 2
                    Text { text: qsTr("实付金额"); color: Theme.text_secondary; font.pixelSize: 12 }
                    Text { text: "¥" + wallet.amount + ".00"; color: Theme.text_primary
                        font.pixelSize: 26; font.weight: Font.Bold; font.family: "JetBrains Mono" }
                }
            }
        }
    }
}
