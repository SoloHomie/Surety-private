#include "AssetService.h"
#include "../network/ApiClient.h"
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
    QVariantMap b; b["email"]=e; b["asset_type"]=t; b["asset_name"]=n;
    b["description"]=d; b["version"]=v; b["properties"]="{}";
    ApiClient::instance()->post("/api/assets", b, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("createAsset", QString::fromUtf8(r)); emit assetCreated(false, "", QString::fromUtf8(r)); return; }
        QJsonObject o = QJsonDocument::fromJson(r).object();
        QString aid = o["asset_id"].toString();
        QString msg = o["message"].toString();
        emit assetCreated(s==200, aid, msg);
    });
}

void AssetService::addPricing(const QString &aid, const QString &model,
                               const QString &price, const QString &dur) {
    QVariantMap b; b["asset_id"]=aid; b["model"]=model;
    b["price"]=price; b["duration_days"]=dur.isEmpty() ? "0" : dur;
    ApiClient::instance()->post("/api/assets/pricing", b, [this](int s, QByteArray r) {
        QString m = s == 200 ? "pricing added" : QJsonDocument::fromJson(r).object()["message"].toString();
        emit pricingAdded(s==200, m);
    });
}
void AssetService::listPricing(const QString &aid) {
    QVariantMap p; p["asset_id"]=aid;
    ApiClient::instance()->get("/api/assets/pricing", p, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("listPricing", QString::fromUtf8(r)); emit pricingLoaded("[]"); return; }
        QJsonArray arr;
        if(s==200) arr=QJsonDocument::fromJson(r).object()["pricing"].toArray();
        emit pricingLoaded(arrToJson(arr));
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

void AssetService::updateAsset(const QString &e, const QString &aid, const QString &t,
                                const QString &n, const QString &d, const QString &v) {
    QVariantMap b; b["email"]=e; b["asset_id"]=aid; b["asset_type"]=t;
    b["asset_name"]=n; b["description"]=d; b["version"]=v;
    b["properties"]="{}";
    ApiClient::instance()->post("/api/assets/update", b, [this](int s, QByteArray r) {
        if (s == 0) { emit errorOccurred("updateAsset", QString::fromUtf8(r)); emit assetUpdated(false, QString::fromUtf8(r)); return; }
        QString m = QJsonDocument::fromJson(r).object()["message"].toString();
        emit assetUpdated(s==200, m);
    });
}
