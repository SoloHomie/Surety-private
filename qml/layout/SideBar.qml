import QtQuick
import "../themes"
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "../toast"
import "../baseComponents"
import "../js/utils.js" as Utils

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
                ListElement { icon: "qrc:/qml/images/vault_new.svg";   text: "资产" }
                ListElement { icon: "qrc:/qml/images/market_new.svg"; text: "市场" }
                ListElement { icon: "qrc:/qml/images/设置.svg";       text: "设置" }
            }
            delegate: SideBarDelegate {
                Layout.fillWidth: true
                iconImage: icon
                sideText: qsTr(text)
                isSelected: index === sideBar.selectedIndex
                onClicked: sideBar.pageSwitchRequested(index)
            }
        }

        Item { Layout.fillHeight: true }

        // 新人福利按钮
        Rectangle {
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: 44; Layout.preferredHeight: 44; radius: 12
            Layout.leftMargin: 0; Layout.bottomMargin: 20
            clip: false
            color: giftClaimed ? Theme.bg_input : (giftBtn.containsMouse ? Theme.hover_bg : Theme.bg_card)
            border.width: 1; border.color: giftClaimed ? Theme.border_default : Theme.accent
            opacity: giftClaimed ? 0.4 : 1.0

            Image { anchors.centerIn: parent; source: "qrc:/qml/images/礼物.svg"
                width: 22; height: 22; fillMode: Image.PreserveAspectFit }

            Tooltip {
                text: giftTooltip || qsTr("Homie为你准备的一点小礼物，以后礼物发放都在这里")
                shown: giftBtn.containsMouse && !giftClaimed
                maxWidth: 220
                arrowVisible: false
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.left: parent.left
            }

            MouseArea {
                id: giftBtn; anchors.fill: parent; hoverEnabled: true
                cursorShape: (giftClaimed || !Api.isLoggedIn) ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    if (giftClaimed) return
                    if (!Api.isLoggedIn) { ToastManager.add(qsTr("登录后可以领取新人福利哦"), "info", "", 2500); return }
                    Api.claimBenefit()
                }
            }
        }
    }

    property bool giftClaimed: false
    property string giftTooltip: ""

    Connections {
        target: Api
        function onBenefitsChecked(claimedTypes) { giftClaimed = claimedTypes.indexOf("welcome") >= 0 }
        function onBenefitsReady(list) {
            if (list.length > 0) giftTooltip = list[0].description || ""
        }
        function onBenefitClaimed(ok, msg) {
            if (ok) { giftClaimed = true; Api.fetchBalance(); Api.fetchTransactions(); ToastManager.add(msg, "success", qsTr("领取成功"), 3000) }
            else ToastManager.add(msg, "warning", "", 2500)
        }
        function onAuthChanged() { if (Api.isLoggedIn) { Api.checkBenefits(); Api.fetchBenefits() } }
    }

}
