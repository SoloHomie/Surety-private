import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    width: 48; height: 48
    radius: 10

    property string iconSource: ""
    property int    iconSize:  22
    property string tooltip:   ""
    property bool   isAddSlot: false

    signal clicked()

    color: {
        if (isAddSlot) return btnMA.containsMouse ? "#21262d" : "transparent"
        return btnMA.containsMouse ? "#1f6feb" : "transparent"
    }
    border.width: 1
    border.color: {
        if (isAddSlot) return btnMA.containsMouse ? "#30363d" : "#21262d"
        return btnMA.containsMouse ? "transparent" : "#21262d"
    }

    Behavior on color       { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }

    MouseArea {
        id: btnMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Image {
        anchors.centerIn: parent
        width: root.iconSize; height: root.iconSize
        source: root.iconSource
        sourceSize.width: root.iconSize * 2
        sourceSize.height: root.iconSize * 2
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: root.iconSource !== ""
        opacity: btnMA.containsMouse ? 1.0 : (isAddSlot ? 0.4 : 0.65)
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    ToolTip {
        visible: btnMA.containsMouse && root.tooltip !== ""
        text: root.tooltip
        delay: 400
    }
}
