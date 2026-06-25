import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../baseComponents"

ScrollPage {
    Text {
        text: "常规设置"
        color: "#e6edf3"
        font.pixelSize: 32; font.weight: Font.Bold
        font.family: "Microsoft YaHei UI"
        Layout.bottomMargin: 24
    }

    SectionHeader { title: "存储" }
    Item { Layout.preferredHeight: 12 }

    RowLayout {
        spacing: 8

        SuretyTextField {
            id: assetPathField
            Layout.fillWidth: true
            placeholder: "D:/SuretyForge/Assets"
        }

        SuretyBtn {
            text: "选择"
            width: 64; height: 44
            variant: "outline"
            font.pixelSize: 14; font.weight: Font.DemiBold
            font.family: "Microsoft YaHei UI"
            onClicked: folderDialog.open()
        }
    }

    FolderDialog {
        id: folderDialog
        currentFolder: assetPathField.text || "file:///D:/"
        onAccepted: {
            var raw = selectedFolder.toString()
            // Windows: file:///D:/... → D:/...
            // Unix:    file:///home/... → /home/...
            var path = raw.replace(/^file:\/{2,3}/, "")
            assetPathField.text = decodeURIComponent(path)
        }
    }

    Item { Layout.preferredHeight: 24 }

    SectionHeader { title: "语言" }
    Item { Layout.preferredHeight: 12 }

    SuretyTagSelector {
        displayMode: "segment"
        minimumWidth: 0
        model: [ { label: "简体中文" }, { label: "English" } ]
        selectedIndex: 0
    }
}
