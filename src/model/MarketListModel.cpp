#include "MarketListModel.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QMap>

// 资产类型 → 展示色
static QString colorForType(const QString &type) {
    // 预设类型统一蓝色，其他自定义紫色
    static QStringList presets = {"Skill","Script","Tool","Model","Workflow","Prompt",
                                   "知识包","脚本","工具","模型","工作流"};
    return presets.contains(type) ? "#58a6ff" : "#a371f7";
}

QHash<int,QByteArray> MarketListModel::roleNames() const {
    return {{MName,"mname"},{MType,"mtype"},{MColor,"mcolor"},{MDesc,"mdesc"},
            {MAuthor,"mauthor"},
            {MOncePrice,"moncePrice"},{MSubPrice,"msubPrice"},{MSubDuration,"msubDuration"},
            {MFav,"mfav"},{MListingId,"mlistingId"},{MVersion,"mversion"},{MSellerId,"msellerId"}};
}
int MarketListModel::rowCount(const QModelIndex &) const { return m_data.size(); }
QVariant MarketListModel::data(const QModelIndex &idx, int role) const {
    if (idx.row()<0 || idx.row()>=m_data.size()) return {};
    auto &o = m_data[idx.row()];
    switch (role) {
    case MName: return o["name"]; case MType: return o["type"];
    case MColor: return o["color"]; case MDesc: return o["desc"];
    case MAuthor: return o["author"];
    case MOncePrice: return o["oncePrice"]; case MSubPrice: return o["subPrice"];
    case MSubDuration: return o["subDuration"];
    case MFav: return o["fav"]; case MListingId: return o["listingId"];
    case MVersion: return o["version"]; case MSellerId: return o["sellerId"];
    default: return {};
    }
}
void MarketListModel::loadFromJson(const QString &json) {
    beginResetModel(); m_data.clear();
    QJsonArray arr = QJsonDocument::fromJson(json.toUtf8()).array();
    for (auto v : arr) {
        auto l = v.toObject(); auto a = l["asset"].toObject();
        auto p = l["pricing"].toObject(); auto s = l["seller"].toObject();
        QVariantMap m;
        m["name"]     = a["name"].toString();
        m["type"]     = a["type"].toString("other");
        m["color"]    = colorForType(a["type"].toString("other"));
        m["desc"]     = a["description"].toString();
        m["author"]   = s["name"].toString();
        m["sellerId"] = s["id"].isString() ? s["id"].toString()
                        : QString::number((qint64)s["id"].toDouble(), 'f', 0);
        m["oncePrice"]= p["once_price"].toDouble();
        m["subPrice"] = p["sub_price"].toDouble();
        m["subDuration"] = p["sub_duration_days"].toInt(30);
        m["fav"]      = false;
        if (l["listing_id"].isString())
            m["listingId"] = l["listing_id"].toString();
        else
            m["listingId"] = QString::number((qint64)l["listing_id"].toDouble(), 'f', 0);
        m["version"]  = a["version"].toString("1.0");
        m_data.append(m);
    }
    endResetModel();
}
void MarketListModel::clear() { beginResetModel(); m_data.clear(); endResetModel(); }
void MarketListModel::prependItem(const QVariantMap &item) {
    beginInsertRows({}, 0, 0);
    m_data.prepend(item);
    endInsertRows();
}
QVariantMap MarketListModel::get(int row) const {
    return (row>=0 && row<m_data.size()) ? m_data[row] : QVariantMap();
}
