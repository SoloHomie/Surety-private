import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#161b22"
    radius: 24
    border.width: 1
    border.color: "#30363d"

    Layout.preferredWidth: 220
    Layout.preferredHeight: 140
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string label: ""
    property string value: ""
    property int    entranceDelay: 0

    opacity: 0
    scale: 0.92

    Component.onCompleted: {
        entranceTimer.interval = root.entranceDelay
        entranceTimer.start()
    }

    Timer {
        id: entranceTimer
        interval: 0
        onTriggered: { opacity = 1.0; scale = 1.0 }
    }

    Behavior on scale   { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
    Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

    Text {
        id: labelText
        height: 24
        color: "#8b949e"
        text: root.label
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 24; anchors.rightMargin: 24; anchors.topMargin: 16
        font.pixelSize: 16
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.weight: Font.Medium
        font.family: "Microsoft YaHei UI"
    }

    Text {
        id: valueText
        color: "#ffffff"
        text: root.value
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: labelText.bottom; anchors.bottom: parent.bottom
        anchors.leftMargin: 24; anchors.rightMargin: 24
        anchors.topMargin: 0; anchors.bottomMargin: 12
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.weight: Font.Bold
        font.family: "JetBrains Mono"
    }
}
