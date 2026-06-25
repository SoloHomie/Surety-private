#include "MarketListModel.h"
#include <QJsonDocument>
#include <QJsonObject>

QHash<int,QByteArray> MarketListModel::roleNames() const {
    return {{MName,"mname"},{MType,"mtype"},{MColor,"mcolor"},{MDesc,"mdesc"},
            {MAuthor,"mauthor"},{MPrice,"mprice"},{MFav,"mfav"},
            {MListingId,"mlistingId"},{MPricingModel,"mpricingModel"},{MDuration,"mduration"}};
}
int MarketListModel::rowCount(const QModelIndex &) const { return m_data.size(); }
QVariant MarketListModel::data(const QModelIndex &idx, int role) const {
    if (idx.row()<0 || idx.row()>=m_data.size()) return {};
    auto &o = m_data[idx.row()];
    switch (role) {
    case MName: return o["name"]; case MType: return o["type"];
    case MColor: return o["color"]; case MDesc: return o["desc"];
    case MAuthor: return o["author"]; case MPrice: return o["price"];
    case MFav: return o["fav"]; case MListingId: return o["listingId"];
    case MPricingModel: return o["pricingModel"]; case MDuration: return o["duration"];
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
        m["name"]=a["name"].toString(); m["type"]=a["type"].toString("other");
        m["color"]="#1f6feb"; m["desc"]=a["description"].toString();
        m["author"]=s["name"].toString();
        m["price"]=QString::number(p["price"].toDouble());
        m["fav"]=false;
        // Use string representation from JSON to avoid double precision loss
        if (l["listing_id"].isString())
            m["listingId"] = l["listing_id"].toString();
        else
            m["listingId"] = QString::number((qint64)l["listing_id"].toDouble(), 'f', 0);
        m["pricingModel"]=p["model"].toString("once");
        m["duration"]=p["duration_days"].toInt(0);
        m_data.append(m);
    }
    endResetModel();
}
void MarketListModel::clear() { beginResetModel(); m_data.clear(); endResetModel(); }
QVariantMap MarketListModel::get(int row) const {
    return (row>=0 && row<m_data.size()) ? m_data[row] : QVariantMap();
}
