#include "ApiClient.h"
#include "../model/AssetListModel.h"
#include <QMap>
#include <QSettings>
#define NOMINMAX
#include <windows.h>
#include <dpapi.h>
#pragma comment(lib, "crypt32.lib")

ApiClient* ApiClient::instance() {
    static ApiClient s;
    return &s;
}

static QByteArray protectData(const QByteArray &plain) {
    DATA_BLOB in, out;
    in.pbData = (BYTE*)plain.constData();
    in.cbData = plain.size();
    if (!CryptProtectData(&in, L"SuretySession", nullptr, nullptr, nullptr, 0, &out))
        return {};
    QByteArray result((const char*)out.pbData, out.cbData);
    LocalFree(out.pbData);
    return result.toBase64();
}

static QByteArray unprotectData(const QByteArray &b64) {
    QByteArray cipher = QByteArray::fromBase64(b64);
    DATA_BLOB in, out;
    in.pbData = (BYTE*)cipher.constData();
    in.cbData = cipher.size();
    if (!CryptUnprotectData(&in, nullptr, nullptr, nullptr, nullptr, 0, &out))
        return {};
    QByteArray result((const char*)out.pbData, out.cbData);
    LocalFree(out.pbData);
    return result;
}

ApiClient::ApiClient(QObject *parent) : QObject(parent) {}

void ApiClient::setupRequest(QNetworkRequest &req) {
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    req.setTransferTimeout(15000); // 15 second timeout
    if (!m_accessToken.isEmpty())
        req.setRawHeader("Authorization", ("Bearer " + m_accessToken).toUtf8());
}

void ApiClient::get(const QString &path, const QVariantMap &params, ApiCallback cb) {
    QUrl url(m_baseUrl + path);
    if (!params.isEmpty()) {
        QUrlQuery q;
        for (auto it = params.cbegin(); it != params.cend(); ++it)
            q.addQueryItem(it.key(), it.value().toString());
        url.setQuery(q);
    }
    QNetworkRequest req(url);
    setupRequest(req);
    auto *reply = m_nam.get(req);
    connect(reply, &QNetworkReply::finished, this, [reply, cb]() {
        int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QByteArray data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            if (cb) cb(0, reply->errorString().toUtf8());
        } else {
            if (cb) cb(status, data);
        }
        reply->deleteLater();
    });
}

void ApiClient::post(const QString &path, const QVariantMap &body, ApiCallback cb) {
    QNetworkRequest req(QUrl(m_baseUrl + path));
    setupRequest(req);
    auto *reply = m_nam.post(req, QJsonDocument(QJsonObject::fromVariantMap(body)).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this, [reply, cb]() {
        int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QByteArray data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            if (cb) cb(0, reply->errorString().toUtf8());
        } else {
            if (cb) cb(status, data);
        }
        reply->deleteLater();
    });
}

void ApiClient::setAuth(const QString &json) {
    QJsonObject o = QJsonDocument::fromJson(json.toUtf8()).object();
    auto take = [&](const char *key, QString &field) {
        QString v = o[key].toString();
        if (!v.isEmpty()) field = v;
    };
    take("access_token",  m_accessToken);
    take("refresh_token", m_refreshToken);
    take("uid",           m_uid);
    take("email",         m_email);
    take("username",      m_username);
    take("avatar",        m_avatarUrl);
    take("provider",      m_provider);
    emit authChanged();
}

void ApiClient::clearAuth() {
    m_accessToken.clear();
    m_refreshToken.clear();
    m_uid.clear();
    m_email.clear();
    m_username.clear();
    m_avatarUrl.clear();
    m_assetCount = 0; m_listedCount = 0; m_subCount = 0;
    emit assetCountChanged(); emit listedCountChanged(); emit subCountChanged();
    QSettings s("Surety", "Surety");
    s.remove("refreshToken");
    s.remove("email");
    s.remove("uid");
    s.remove("username");
    emit authChanged();
}

void ApiClient::saveSession() {
    QSettings s("Surety", "Surety");
    s.setValue("refreshToken", protectData(m_refreshToken.toUtf8()));
    s.setValue("email", protectData(m_email.toUtf8()));
    s.setValue("uid", m_uid);
    s.setValue("username", m_username);
}

void ApiClient::loadSession() {
    QSettings s("Surety", "Surety");
    m_refreshToken = QString::fromUtf8(unprotectData(s.value("refreshToken").toByteArray()));
    m_email        = QString::fromUtf8(unprotectData(s.value("email").toByteArray()));
    m_uid          = s.value("uid").toString();
    m_username     = s.value("username").toString();
}

void ApiClient::tryAutoLogin() {
    loadSession();
    if (m_refreshToken.isEmpty()) return;
    QVariantMap b; b["refresh_token"] = m_refreshToken;
    post("/api/auth/refresh", b, [this](int s, QByteArray r) {
        bool ok = (s == 200);
        if (ok) { setAuth(QString::fromUtf8(r)); saveSession(); fetchStats(); fetchDevLogs(); }
        else clearAuth();
        emit autoLoginFinished(ok);
    });
}

// ── 从服务器拉初始化统计（登录后调用）────────────────
void ApiClient::fetchStats() {
    if (m_email.isEmpty()) { updateLocalStats(); return; }
    QVariantMap p; p["email"] = m_email;
    get("/api/stats", p, [this](int s, QByteArray r) {
        if (s == 200) {
            QJsonObject o = QJsonDocument::fromJson(r).object();
            m_assetCount  = o["total_assets"].toInt();
            m_listedCount = o["active_listings"].toInt();
            m_subCount    = o["subscription_count"].toInt();
        } else {
            updateLocalStats();
        }
        emit assetCountChanged();
        emit listedCountChanged();
        emit subCountChanged();
    });
}

// ── 本地统计：从 model 直接算（客户端操作后乐观更新）──
void ApiClient::updateLocalStats() {
    if (m_assetModel) {
        m_assetCount  = m_assetModel->count();
        m_listedCount = m_assetModel->countByField("quick", true);
        emit assetCountChanged();
        emit listedCountChanged();
    }
    if (m_subModel) {
        m_subCount = m_subModel->count();
        emit subCountChanged();
    }
}

// ── 快速上架 ─────────────────────────────────────────
void ApiClient::quickListAsset(const QString &assetId) {
    QVariantMap b; b["email"] = m_email; b["asset_id"] = assetId;
    post("/api/listings/quick", b, [this, assetId](int s, QByteArray) {
        if (s == 200 && m_assetModel) {
            // 成功后更新 model 中该资产的 quick=true
            QVariantMap f; f["quick"] = true;
            m_assetModel->updateItem(assetId, f);
            updateLocalStats();
        }
    });
}

// ── 快速下架 ─────────────────────────────────────────
void ApiClient::quickUnlistAsset(const QString &assetId) {
    QVariantMap b; b["email"] = m_email; b["asset_id"] = assetId;
    post("/api/listings/quick-cancel", b, [this, assetId](int s, QByteArray) {
        if (s == 200 && m_assetModel) {
            // 成功后更新 model 中该资产的 quick=false
            QVariantMap f; f["quick"] = false;
            m_assetModel->updateItem(assetId, f);
            updateLocalStats();
        }
    });
}

void ApiClient::fetchOAuthLinks() {
    QVariantMap p; p["email"] = m_email;
    get("/api/auth/oauth/links", p, [this](int s, QByteArray r) {
        if (s != 200) return;
        QJsonArray arr = QJsonDocument::fromJson(r).object()["links"].toArray();
        m_oauthLinks.clear();
        for (auto v : arr) {
            QJsonObject o = v.toObject();
            QVariantMap m;
            m["provider"]    = o["provider"].toString();
            m["providerId"]  = o["provider_id"].toString();
            m["providerUid"] = o["provider_uid"].toString();
            m_oauthLinks.append(m);
        }
        emit oauthLinksChanged();
    });
}

void ApiClient::unlinkOAuth(const QString &provider) {
    QVariantMap b; b["email"] = m_email; b["provider"] = provider;
    post("/api/auth/oauth/unlink", b, [this](int s, QByteArray) {
        if (s == 200) fetchOAuthLinks();
    });
}

void ApiClient::checkUpdate() {
    get("/api/version", {}, [this](int s, QByteArray r) {
        if (s == 200) {
            QJsonObject o = QJsonDocument::fromJson(r).object();
            QString serverVer = o["version"].toString();
            QString currentVer = "1.0.0";
            // 语义化版本比较
            auto compareVer = [](const QString &a, const QString &b) -> int {
                auto al = a.split('.'), bl = b.split('.');
                for (int i = 0; i < qMax(al.size(), bl.size()); ++i) {
                    int av = i < al.size() ? al[i].toInt() : 0;
                    int bv = i < bl.size() ? bl[i].toInt() : 0;
                    if (av != bv) return av - bv;
                }
                return 0;
            };
            bool hasUpdate = compareVer(serverVer, currentVer) > 0;
            emit updateCheckFinished(hasUpdate, serverVer,
                                     o["download_url"].toString());
        } else {
            QString err = s == 0 ? QString::fromUtf8(r) : QString("HTTP %1").arg(s);
            emit updateCheckFinished(false, "", err);
        }
    });
}

void ApiClient::fetchDevLogs() {
    get("/api/dev-logs", {}, [this](int s, QByteArray r) {
        if (s != 200) return;
        QJsonArray arr = QJsonDocument::fromJson(r).object()["logs"].toArray();
        m_devLogs.clear();
        static QMap<QString,QString> colors;
        if (colors.empty()) {
            colors["feature"]     = "#238636";
            colors["fix"]         = "#da3633";
            colors["improvement"] = "#8957e5";
            colors["release"]     = "#1f6feb";
        }
        for (int i = 0; i < arr.size(); ++i) {
            QJsonObject o = arr[i].toObject();
            QVariantMap m;
            QString logType = o["log_type"].toString();
            m["title"]       = o["title"].toString();
            m["message"]     = o["description"].toString();
            m["time"]        = o["created_at"].toString();
            m["version"]     = o["version"].toString();
            m["logType"]     = logType;
            m["color"]       = colors.value(logType, "#8b949e");
            m["expanded"]    = (i == 0);
            m_devLogs.append(m);
        }
        emit devLogsChanged();
    });
}
