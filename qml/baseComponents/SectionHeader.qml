import QtQuick
import "../themes"

// ═══════════════════════════════════════════════════════════════════════════════
//  SectionHeader — 设置页分节标题
// ═══════════════════════════════════════════════════════════════════════════════
Item {
    id: root

    property string title:     ""
    property color  barColor:  Theme.accent

    width:  parent ? parent.width : 240
    height: 26

    Row {
        spacing: 12

        Rectangle {
            width: 4
            height: 22
            radius: 2
            color: root.barColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.title
            color: Theme.text_primary
            font.pixelSize: 20
            font.weight: Font.Bold
            font.family: "Microsoft YaHei UI"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
