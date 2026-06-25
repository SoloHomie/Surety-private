import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

ScrollPage {
    Text {
        text: "外观设置"
        color: "#e6edf3"
        font.pixelSize: 32; font.weight: Font.Bold
        font.family: "Microsoft YaHei UI"
        Layout.bottomMargin: 24
    }

    SectionHeader { title: "主题" }
    Item { Layout.preferredHeight: 12 }

    SuretyTagSelector {
        displayMode: "segment"
        minimumWidth: 0
        model: [ { label: "暗色深空" }, { label: "亮色晨光" } ]
        selectedIndex: 0
    }

    Item { Layout.preferredHeight: 24 }

    SectionHeader { title: "字体" }
    Item { Layout.preferredHeight: 12 }

    SuretyTagSelector {
        displayMode: "segment"
        minimumWidth: 0
        model: [ { label: "JetBrains Mono" }, { label: "微软雅黑" } ]
        selectedIndex: 0
    }
}
