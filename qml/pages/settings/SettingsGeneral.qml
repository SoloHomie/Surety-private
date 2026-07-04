import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../baseComponents"
import "../../toast"

ScrollPage {
    id: page

    // ── 迁移加载遮罩 ──
    Connections {
        target: FileHelper
        function onIsMigratingChanged() {
            if (FileHelper.isMigrating) loadingOverlay.open()
            else loadingOverlay.close()
        }
    }

    Popup {
        id: loadingOverlay
        anchors.centerIn: Overlay.overlay
        width: 260; height: 160
        closePolicy: Popup.NoAutoClose
        modal: true
        background: Rectangle { radius: 16; color: Theme.bg_card; border.width: 1; border.color: Theme.border_standard }

        ColumnLayout {
            anchors.centerIn: parent; spacing: 16
            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: true
                implicitWidth: 48; implicitHeight: 48
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("正在迁移文件...")
                color: Theme.text_primary; font.pixelSize: 16; font.weight: Font.DemiBold
                font.family: "Microsoft YaHei UI"
            }
            Text {
                id: progressText
                Layout.alignment: Qt.AlignHCenter
                text: "0%"
                color: Theme.text_secondary; font.pixelSize: 14
                font.family: "JetBrains Mono"
            }
        }
    }

    Connections {
        target: FileHelper
        function onMigrateProgress(pct) { progressText.text = pct + "%" }
    }

    Text {
        text: qsTr("常规设置")
        color: Theme.text_primary
        font.pixelSize: 32; font.weight: Font.Bold
        font.family: "Microsoft YaHei UI"
        Layout.bottomMargin: 24
    }

    SectionHeader { title: qsTr("存储") }
    Item { Layout.preferredHeight: 12 }

    Text {
        text: qsTr("资产数据存储位置（更改后自动迁移已有文件）")
        color: Theme.text_secondary; font.pixelSize: 14
        font.family: "Microsoft YaHei UI"
    }

    RowLayout {
        spacing: 8

        SuretyTextField {
            id: pathField
            Layout.fillWidth: true
            text: FileHelper.dataPath()
            readOnly: true
        }

        SuretyBtn {
            text: qsTr("更改")
            width: 64; height: 44
            variant: "outline"
            font.pixelSize: 14; font.weight: Font.DemiBold
            onClicked: folderDialog.open()
        }
    }

    FolderDialog {
        id: folderDialog
        currentFolder: pathField.text ? "file:///" + pathField.text : "file:///D:/"
        onAccepted: {
            var raw = selectedFolder.toString()
            var newPath = decodeURIComponent(raw.replace(/^file:\/{2,3}/, ""))
            if (newPath === pathField.text) return
            FileHelper.setDataPath(newPath)
        }
    }

    Connections {
        target: FileHelper
        function onMigrateFinished(ok, msg) {
            if (ok) {
                pathField.text = FileHelper.dataPath()
                ToastManager.add("存储位置已更新", "success", "设置成功", 3000)
            } else {
                ToastManager.add(msg, "error", "操作失败", 3000)
            }
        }
    }

    Item { Layout.preferredHeight: 24 }

    SectionHeader { title: qsTr("语言") }
    Item { Layout.preferredHeight: 12 }

    SuretyTagSelector {
        id: langSelector
        displayMode: "segment"
        minimumWidth: 0
        model: page.langModel
        selectedIndex: Lang.currentLanguage === "en" ? 1 : 0
        onTagSelected: function(idx) {
            Lang.setLanguage(idx === 1 ? "en" : "zh")
        }
    }

    property var langModel: [
        { label: qsTr("简体中文") },
        { label: qsTr("English") }
    ]

    Connections {
        target: Lang
        function onLanguageChanged() {
            page.langModel = [
                { label: qsTr("简体中文") },
                { label: qsTr("English") }
            ]
            langSelector.selectedIndex = Lang.currentLanguage === "en" ? 1 : 0
        }
    }
}
