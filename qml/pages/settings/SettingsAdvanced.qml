import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

ScrollPage {
    Text {
        text: qsTr("高级设置")
        color: Theme.text_primary
        font.pixelSize: 32; font.weight: Font.Bold
        font.family: "Microsoft YaHei UI"
        Layout.bottomMargin: 24
    }

    SectionHeader { title: qsTr("网络") }
    Item { Layout.preferredHeight: 12 }

    SuretyTextField {
        Layout.fillWidth: true
        label: qsTr("API 端点")
        placeholder: "https://api.surety.io/v1"
    }
}
