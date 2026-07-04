import QtQuick
import "../themes"

Rectangle {
    id: root
    width: 48; height: 48
    radius: 12

    property string name: ""
    property color accentColor: Theme.accent_text
    property real bgOpacity: 0.12
    property int fontSize: 28
    property string fontFamily: "Arial"

    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, root.bgOpacity)

    Text {
        anchors.centerIn: parent
        text: root.name.charAt(0)
        color: root.accentColor
        font.pixelSize: root.fontSize
        font.weight: Font.Bold
        font.family: root.fontFamily
    }
}
