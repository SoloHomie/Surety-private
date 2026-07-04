import QtQuick
import "../../themes"
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0

RowLayout {
    id: rowLayout
    height: 170
    spacing: 24
    uniformCellSizes: true

    StatCard { label: qsTr("资产总数"); value: Api.assetCount.toString(); entranceDelay: 0   }
    StatCard { label: qsTr("上架数量"); value: Api.listedCount.toString(); entranceDelay: 60  }
    StatCard { label: qsTr("订阅数量"); value: Api.subCount.toString(); entranceDelay: 120 }
    StatCard { label: qsTr("待审核");   value: "0";                      entranceDelay: 180 }
    StatCard { label: qsTr("余额") + " (Surety)"; value: "" + Api.suretyBalance; entranceDelay: 240 }
}
