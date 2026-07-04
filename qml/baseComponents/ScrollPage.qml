import QtQuick
import "../themes"
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root

    property int contentMaxWidth: 560
    property int contentAlignment: Qt.AlignLeft

    default property alias contentData: column.data

    Flickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight + 60
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: SuretyScrollBar { }

        // 失焦背景：放 ColumnLayout 下面，填满整个 content 区域
        MouseArea {
            anchors.fill: parent
            onClicked: root.forceActiveFocus()
        }

        ColumnLayout {
            id: column
            width: Math.min(parent.width - 64, root.contentMaxWidth)

            anchors.left: root.contentAlignment === Qt.AlignLeft ? parent.left : undefined
            anchors.leftMargin: root.contentAlignment === Qt.AlignLeft ? 32 : 0
            anchors.horizontalCenter: root.contentAlignment === Qt.AlignHCenter ? parent.horizontalCenter : undefined
            anchors.top: parent.top
            anchors.topMargin: 32
            spacing: 0
        }
    }

}
