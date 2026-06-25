import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Surety 1.0

RowLayout {
    id: rowLayout
    height: 170
    spacing: 24
    uniformCellSizes: true

    StatCard { label: "资产总数"; value: Api.assetCount.toString();  entranceDelay: 0   }
    StatCard { label: "上架数量"; value: Api.listedCount.toString(); entranceDelay: 60  }
    StatCard { label: "订阅数量"; value: Api.subCount.toString();    entranceDelay: 120 }
    StatCard { label: "待审核";   value: "0";                        entranceDelay: 180 }
}
