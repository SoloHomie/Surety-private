import QtQuick
import "../../themes"
import QtQuick.Controls

//=============================================================================
// ActiveItemDetail — 活动项展开详情卡片（纯展示消息内容）
//=============================================================================
Rectangle {
    id: root
    implicitWidth: 360
    implicitHeight: detailColumn.implicitHeight + 32
    color: Theme.bg_page
    radius: 10
    border.width: 1
    border.color: Theme.border_standard

    // ── 外部属性 ──
    property string message: ""

    Column {
        id: detailColumn
        anchors.left: parent.left;   anchors.leftMargin: 20
        anchors.right: parent.right; anchors.rightMargin: 20
        anchors.top: parent.top;     anchors.topMargin: 16
        spacing: 0

        // 消息正文
        Text {
            id: msgText
            anchors.left: parent.left
            anchors.right: parent.right
            text: root.message || "暂无详细信息。"
            color: root.message !== "" ? Theme.text_primary : Theme.text_disabled
            font.pixelSize: 15
            font.family: "Microsoft YaHei UI"
            wrapMode: Text.WordWrap
            lineHeight: 1.5
            textFormat: Text.PlainText
            maximumLineCount: 15
            elide: Text.ElideRight
        }
    }
}
