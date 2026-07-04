import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "../../baseComponents"

ScrollPage {
    Text {
        text: qsTr("外观设置")
        color: Theme.text_primary
        font.pixelSize: 32; font.weight: Font.Bold
        font.family: "Microsoft YaHei UI"
        Layout.bottomMargin: 24
    }

    SectionHeader { title: qsTr("主题") }
    Item { Layout.preferredHeight: 12 }

    SuretyTagSelector {
        displayMode: "segment"
        minimumWidth: 0
        model: [ { label: qsTr("暗色深空") }]
        selectedIndex: 0
    }

    Item { Layout.preferredHeight: 24 }

    SectionHeader { title: qsTr("字体") }
    Item { Layout.preferredHeight: 12 }

    SuretyTagSelector {
        displayMode: "segment"
        minimumWidth: 0
        model: [ { label: qsTr("微软雅黑") } ]
        selectedIndex: 0
    }
}
