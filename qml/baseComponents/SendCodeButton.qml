import QtQuick

Rectangle {
    id: root
    implicitWidth: 130; implicitHeight: 44
    radius: 8

    property int  countdown: 0
    property bool sending:   false
    signal clicked()

    readonly property bool _disabled: countdown > 0 || sending

    color: {
        if (_disabled) return "#21262d"
        if (btnHover.containsMouse) return "#388bfd"
        return "#1f6feb"
    }
    border.width: 1
    border.color: _disabled ? "#30363d" : "transparent"
    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: sending ? "发送中..." : (countdown > 0 ? countdown + "s 后重发" : "发送验证码")
        color: _disabled ? "#484f58" : "#ffffff"
        font.pixelSize: 13; font.weight: Font.DemiBold
        font.family: "Microsoft YaHei UI"
    }

    MouseArea {
        id: btnHover
        anchors.fill: parent; hoverEnabled: true
        cursorShape: _disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !_disabled
        onClicked: root.clicked()
    }
}
