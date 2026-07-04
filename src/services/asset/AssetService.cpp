#include "AssetService.h"
#include "../../network/ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

AssetService* AssetService::instance() { static AssetService s; return &s; }

QString AssetService::arrToJson(const QJsonArray &arr) {
    return QString::fromUtf8(QJsonDocument(arr).toJson(QJsonDocument::Compact));
}

void AssetService::listAssets(const QString &e, const QString &t) {
    QVariantMap p; p["email"]=e; if(!t.isEmpty()) p["type"]=t;
    ApiClient::instance()->get("/api/assets", p, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("listAssets", QString::fromUtf8(r)); emit assetsLoaded("[]"); return; }
        QJsonArray arr;
        if(s==200) arr=QJsonDocument::fromJson(r).object()["assets"].toArray();
        emit assetsLoaded(arrToJson(arr));
    });
}
void AssetService::createAsset(const QString &e, const QString &t, const QString &n,
                                const QString &d, const QString &v) {
    createAssetFull(e, t, n, d, v, "", "", "");
}

void AssetService::createAssetFull(const QString &e, const QString &t, const QString &n,
                                    const QString &d, const QString &v,
                                    const QString &onceP, const QString &subP, const QString &subD) {
    QVariantMap b; b["email"]=e; b["asset_type"]=t; b["asset_name"]=n;
    b["description"]=d; b["version"]=v; b["properties"]="{}";
    if (!onceP.isEmpty()) b["once_price"] = onceP;
    if (!subP.isEmpty())  b["sub_price"]  = subP;
    if (!subD.isEmpty())  b["sub_duration_days"] = subD;
    ApiClient::instance()->post("/api/assets", b, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("createAsset", QString::fromUtf8(r)); emit assetCreated(false, "", QString::fromUtf8(r)); return; }
        QJsonObject o = QJsonDocument::fromJson(r).object();
        QString aid = o["asset_id"].toString();
        QString msg = o["message"].toString();
        emit assetCreated(s==200, aid, msg);
    });
}

void AssetService::updateAsset(const QString &e, const QString &aid, const QString &t,
                                const QString &n, const QString &d, const QString &v) {
    updateAssetFull(e, aid, t, n, d, v, "", "", "");
}

void AssetService::updateAssetFull(const QString &e, const QString &aid, const QString &t,
                                    const QString &n, const QString &d, const QString &v,
                                    const QString &onceP, const QString &subP, const QString &subD) {
    QVariantMap b; b["email"]=e; b["asset_id"]=aid; b["asset_type"]=t;
    b["asset_name"]=n; b["description"]=d; b["version"]=v;
    b["properties"]="{}";
    if (!onceP.isEmpty()) b["once_price"] = onceP;
    if (!subP.isEmpty())  b["sub_price"]  = subP;
    if (!subD.isEmpty())  b["sub_duration_days"] = subD;
    ApiClient::instance()->post("/api/assets/update", b, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("updateAsset", QString::fromUtf8(r)); emit assetUpdated(false, QString::fromUtf8(r)); return; }
        QString m = QJsonDocument::fromJson(r).object()["message"].toString();
        emit assetUpdated(s==200, m);
    });
}

void AssetService::deleteAsset(const QString &e, const QString &aid) {
    QVariantMap b; b["email"]=e; b["asset_id"]=aid;
    ApiClient::instance()->post("/api/assets/delete", b, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("deleteAsset", QString::fromUtf8(r)); return; }
        emit assetUpdated(s==200, QJsonDocument::fromJson(r).object()["message"].toString());
    });
}

void AssetService::listSubscriptions(const QString &e) {
    QVariantMap p; p["email"]=e;
    ApiClient::instance()->get("/api/subscriptions", p, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("listSubscriptions", QString::fromUtf8(r)); emit subscriptionsLoaded("[]"); return; }
        QJsonArray arr;
        if(s==200) arr=QJsonDocument::fromJson(r).object()["subscriptions"].toArray();
        emit subscriptionsLoaded(arrToJson(arr));
    });
}
