import QtQuick
import "../../themes"
import QtQuick.Layouts

Rectangle {
    id: root
    color: Theme.bg_card
    radius: 24
    border.width: 1
    border.color: Theme.border_standard

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
        color: Theme.text_secondary
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
        color: Theme.text_bright
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
