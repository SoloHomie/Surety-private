#include "AssetListModel.h"
#include <QJsonObject>

QHash<int,QByteArray> AssetListModel::roleNames() const {
    return {{Name,"name"},{Type,"type"},{Code,"code"},{Version,"version"},
            {Author,"author"},{HasSub,"hasSubscription"},{AssetId,"assetId"},
            {Desc,"desc"},{Props,"props"},{Quick,"quick"}};
}
int AssetListModel::rowCount(const QModelIndex &) const { return m_data.size(); }
QVariant AssetListModel::data(const QModelIndex &idx, int role) const {
    if (idx.row()<0 || idx.row()>=m_data.size()) return {};
    auto &o = m_data[idx.row()];
    switch (role) {
    case Name: return o["name"]; case Type: return o["type"];
    case Code: return o["code"]; case Version: return o["version"];
    case Author: return o["author"]; case HasSub: return o["hasSubscription"];
    case AssetId: return o["assetId"]; case Desc: return o["desc"];
    case Props: return o["props"]; case Quick: return o["quick"];
    default: return {};
    }
}

void AssetListModel::loadFromJson(const QString &json, bool isSub) {
    beginResetModel(); m_data.clear();
    QJsonArray arr = QJsonDocument::fromJson(json.toUtf8()).array();
    for (auto v : arr) {
        auto o = v.toObject();
        QVariantMap m;
        m["name"]=o["asset_name"].toString();
        m["type"]=o["asset_type"].toString("other");
        m["code"]="#1f6feb";
        m["version"]=o["version"].toString("1.0");
        m["author"]="";
        m["hasSubscription"]=isSub;
        // Use string representation from JSON to avoid double precision loss
        if (o["asset_id"].isString())
            m["assetId"] = o["asset_id"].toString();
        else
            m["assetId"] = QString::number((qint64)o["asset_id"].toDouble(), 'f', 0);
        m["desc"]=o["description"].toString();
        m["quick"]=o["quick"].toBool(false);   // 服务端返回的上架状态
        m["props"]=QString::fromUtf8(QJsonDocument(o["properties"].toObject()).toJson(QJsonDocument::Compact));
        m_data.append(m);
    }
    endResetModel();
    emit countChanged();
}

void AssetListModel::clear() {
    beginResetModel(); m_data.clear(); endResetModel();
    emit countChanged();
}

QVariantMap AssetListModel::get(int row) const {
    return (row>=0 && row<m_data.size()) ? m_data[row] : QVariantMap();
}

int AssetListModel::findRow(const QString &assetId) const {
    for (int i = 0; i < m_data.size(); ++i)
        if (m_data[i]["assetId"].toString() == assetId) return i;
    return -1;
}

void AssetListModel::updateItem(const QString &assetId, const QVariantMap &fields) {
    int row = findRow(assetId);
    if (row < 0) return;
    for (auto it = fields.cbegin(); it != fields.cend(); ++it)
        m_data[row][it.key()] = it.value();
    QModelIndex idx = createIndex(row, 0);
    emit dataChanged(idx, idx);
    emit countChanged();
}

void AssetListModel::removeItem(const QString &assetId) {
    int row = findRow(assetId);
    if (row < 0) return;
    beginRemoveRows({}, row, row);
    m_data.removeAt(row);
    endRemoveRows();
    emit countChanged();
}

int AssetListModel::countByField(const QString &field, bool value) const {
    int n = 0;
    for (auto &m : m_data)
        if (m.value(field).toBool() == value) ++n;
    return n;
}
