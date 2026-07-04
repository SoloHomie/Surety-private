import QtQuick
import "../themes"
import QtQuick.Controls

// ═══════════════════════════════════════════════════════════
//  ToastItem — Toast 卡片模板
// ═══════════════════════════════════════════════════════════
Rectangle {
    id: root
    width: toastWidth
    height: Math.max(minHeight, contentLayout.implicitHeight + vPadding * 2)
    radius: toastRadius

    // ═══════════════════════════════════════════════
    //  布局尺寸（后期直接改这里）
    // ═══════════════════════════════════════════════
    property int toastWidth:  600
    property int minHeight:   140
    property int toastRadius: 12
    property int vPadding:    24
    property int hPadding:    28
    property int iconSize:    40
    property int closeSize:   32
    property int titleSize:   24
    property int msgSize:     20
    property int lineSpacing: 10

    // ═══════════════════════════════════════════════
    //  外部属性
    // ═══════════════════════════════════════════════
    property string toastType: "info"
    property string iconSource: ""
    property string title: ""
    property string message: ""
    property color  bgColor: "transparent"
    property color  borderColor: "transparent"
    property bool   showClose: true
    property bool   showCopy:  toastType === "danger" || toastType === "error"   // 红/错误态显示复制
    property int    duration: 3000

    signal dismissed()

    // ═══════════════════════════════════════════════
    //  硬编码预设
    // ═══════════════════════════════════════════════
    readonly property var _map: ({
        "info":    { bg: Theme.bg_card, bd: Theme.border_standard, svg: "qrc:/qml/images/toast-info.svg" },
        "success": { bg: "#04260f", bd: Theme.success, svg: "qrc:/qml/images/toast-success.svg" },
        "warning": { bg: "#231a03", bd: Theme.warning, svg: "qrc:/qml/images/toast-warning.svg" },
        "danger":  { bg: "#2d050b", bd: Theme.danger, svg: "qrc:/qml/images/toast-danger.svg" },
        "error":   { bg: "#2d050b", bd: Theme.danger, svg: "qrc:/qml/images/toast-danger.svg" }
    })
    readonly property var _m: _map[toastType] || _map["info"]

    readonly property color  _bg:  bgColor.a     > 0 ? bgColor     : _m.bg
    readonly property color  _bd:  borderColor.a > 0 ? borderColor : _m.bd
    readonly property string _svg: iconSource !== ""  ? iconSource : _m.svg

    color: _bg
    border.width: 1
    border.color: _bd

    // ── 隐藏 TextEdit: 供复制按钮调用 ──
    TextEdit {
        id: copyHelper
        visible: false
        text: (root.title ? root.title + "\n" : "") + root.message
    }

    // ── 左侧色条 ──
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 7
        width: 4; radius: 2
        color: root._bd
        visible: toastWidth >= 400
    }

    // ── 悬停 / 点击 ──
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: { if (root.duration > 0) autoDismiss.stop() }
        onExited:  { if (root.duration > 0) autoDismiss.restart() }
        onClicked: root.dismissed()
    }

    // ── 右上按钮区: 关闭 + 复制 ──
    Row {
        anchors.right: parent.right;  anchors.rightMargin: root.hPadding / 2
        anchors.top: parent.top;      anchors.topMargin: root.hPadding / 2
        spacing: 4

        // 复制按钮
        Rectangle {
            visible: root.showCopy
            width: root.closeSize; height: root.closeSize; radius: 4
            color: copyMA.containsMouse ? Theme.border_standard : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
            Image {
                anchors.centerIn: parent
                source: "qrc:/qml/images/toast-copy.svg"
                width: 22; height: 22
                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                id: copyMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    copyHelper.selectAll()
                    copyHelper.copy()
                    copyHelper.deselect()
                }
            }
        }

        // 关闭按钮
        Rectangle {
            visible: root.showClose
            width: root.closeSize; height: root.closeSize; radius: 4
            color: closeMA.containsMouse ? Theme.border_standard : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
            Image {
                anchors.centerIn: parent
                source: "qrc:/qml/images/toast-close.svg"
                width: 22; height: 22
                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                id: closeMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dismissed()
            }
        }
    }

    // ── 内容: 图标 + 文本 ──
    Row {
        id: contentLayout
        anchors.left: parent.left;   anchors.leftMargin: root.hPadding
        anchors.right: parent.right
        anchors.rightMargin: root.showCopy ? (root.closeSize * 2 + root.hPadding + 8) :
                              root.showClose ? (root.closeSize + root.hPadding) : root.hPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        Image {
            source: root._svg
            width: root.iconSize; height: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - root.iconSize - parent.spacing
            spacing: root.lineSpacing

            Text {
                visible: root.title !== ""
                width: parent.width
                text: root.title
                color: Theme.text_primary
                font.pixelSize: root.titleSize; font.weight: Font.Bold
                font.family: "Microsoft YaHei UI"
                elide: Text.ElideRight; maximumLineCount: 1
            }
            Text {
                width: parent.width
                text: root.message
                color: Theme.text_secondary
                font.pixelSize: root.msgSize
                font.family: "Microsoft YaHei UI"
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                lineHeight: 1.5; maximumLineCount: 6
                linkColor: Theme.accent_text
                onLinkActivated: function(link) { Qt.openUrlExternally(link) }
            }
        }
    }

    // ── 自动消失 ──
    Timer {
        id: autoDismiss
        interval: root.duration
        running: root.duration > 0
        repeat: false
        onTriggered: root.dismissed()
    }
}
