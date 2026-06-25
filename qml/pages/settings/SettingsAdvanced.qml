import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

ScrollPage {
    Text {
        text: "高级设置"
        color: "#e6edf3"
        font.pixelSize: 32; font.weight: Font.Bold
        font.family: "Microsoft YaHei UI"
        Layout.bottomMargin: 24
    }

    SectionHeader { title: "网络" }
    Item { Layout.preferredHeight: 12 }

    SuretyTextField {
        Layout.fillWidth: true
        label: "API 端点"
        placeholder: "https://api.surety.io/v1"
    }
}
