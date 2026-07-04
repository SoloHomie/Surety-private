import QtQuick
import "../themes"
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
    color: Theme.bg_input

    signal marketItemRequested(var listing)

    property var hotList: []

    Component.onCompleted: {
        Api.fetchDevLogs()
        Api.fetchHotListings(10)
    }

    Connections {
        target: Api
        function onHotListingsReady(listings) { homePage.hotList = listings }
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
            Layout.preferredWidth: 6
            model: Api.devLogs
        }

        HeatRanking {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 4
            rankings: homePage.hotList

            onItemClicked: function(listing) {
                homePage.marketItemRequested(listing)
            }
        }
    }
}
