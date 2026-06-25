import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0
import "home"

Rectangle {
    id: homePage
    focus: true
    width: 1320
    height: 936
    clip: true
    color: "#010409"

    signal marketItemRequested(string name, string type, string callCount)

    Component.onCompleted: {
        Api.fetchDevLogs()
    }

    PreviewCards {
        id: previewCards
        height: 146
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 24
    }

    RowLayout {
        id: rowLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: previewCards.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 24
        anchors.bottomMargin: 24
        spacing: 24

        TimelineList {
            id: timelineView
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 7
            model: Api.devLogs
        }

        HeatRanking {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 3
            Layout.maximumWidth: 400

            onItemClicked: function(name, type, calls) {
                homePage.marketItemRequested(name, type, calls)
            }
        }
    }
}
