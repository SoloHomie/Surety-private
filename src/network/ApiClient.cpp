#include "ApiClient.h"
#include "../model/AssetListModel.h"
#include "../model/MarketListModel.h"
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

// DPAPI optional entropy — binds encrypted blobs to this application specifically.
// Even another process running as the same user cannot decrypt without this value.
static const BYTE DPAPI_ENTROPY[] = {
    0xA7,0x3F,0xC1,0x88,0x2D,0x5E,0x9B,0x14,0x66,0xF0,0x3D,0x81,0xCA,0x57,0xE2,0x09
};

static QByteArray protectData(const QByteArray &plain) {
    DATA_BLOB in, out, entropy;
    in.pbData = (BYTE*)plain.constData();
    in.cbData = (DWORD)plain.size();
    entropy.pbData = (BYTE*)DPAPI_ENTROPY;
    entropy.cbData = sizeof(DPAPI_ENTROPY);
    if (!CryptProtectData(&in, L"SuretySession", &entropy, nullptr, nullptr, 0, &out))
        return {};
    QByteArray result((const char*)out.pbData, (int)out.cbData);
    LocalFree(out.pbData);
    return result.toBase64();
}

static QByteArray unprotectData(const QByteArray &b64) {
    QByteArray cipher = QByteArray::fromBase64(b64);
    DATA_BLOB in, out, entropy;
    in.pbData = (BYTE*)cipher.constData();
    in.cbData = (DWORD)cipher.size();
    entropy.pbData = (BYTE*)DPAPI_ENTROPY;
    entropy.cbData = sizeof(DPAPI_ENTROPY);
    if (!CryptUnprotectData(&in, nullptr, &entropy, nullptr, nullptr, 0, &out))
        return {};
    QByteArray result((const char*)out.pbData, (int)out.cbData);
    LocalFree(out.pbData);
    return result;
}

ApiClient::ApiClient(QObject *parent) : QObject(parent) {
    m_baseUrl = qEnvironmentVariable("SUREITY_API_URL", "https://api.solohomie.top");
}

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

void ApiClient::subscribe(const QString &listingId) {
    QVariantMap b; b["email"] = m_email; b["listing_id"] = listingId;
    post("/api/subscriptions", b, [this](int s, QByteArray r) {
        QJsonObject o = QJsonDocument::fromJson(r).object();
        bool ok = (s == 200 && o["success"].toBool());
        emit subscribeFinished(ok, o["message"].toString());
    });
}

void ApiClient::claimBenefit(const QString &benefitType) {
    QVariantMap b; b["email"] = m_email; b["benefit_type"] = benefitType;
    post("/api/benefits/claim", b, [this](int s, QByteArray r) {
        QJsonObject o = QJsonDocument::fromJson(r).object();
        bool ok = (s == 200 && o["success"].toBool());
        emit benefitClaimed(ok, ok ? o["message"].toString() : o["message"].toString());
    });
}

void ApiClient::fetchBalance() {
    QVariantMap p; p["email"] = m_email;
    get("/api/wallet/balance", p, [this](int s, QByteArray r) {
        if (s == 200) {
            QJsonObject o = QJsonDocument::fromJson(r).object();
            m_balance = (quint64)o["balance"].toDouble();
            emit suretyBalanceChanged();
        }
    });
}

void ApiClient::fetchTransactions(const QString &type, int page) {
    QVariantMap p; p["email"] = m_email;
    if (!type.isEmpty()) p["type"] = type;
    p["page"] = QString::number(page);
    p["size"] = "50";
    get("/api/transactions", p, [this](int s, QByteArray r) {
        if (s != 200) return;
        QVariantList list;
        QJsonArray arr = QJsonDocument::fromJson(r).object()["transactions"].toArray();
        for (auto v : arr) {
            QJsonObject o = v.toObject();
            QVariantMap m;
            m["type"] = o["type"].toString();
            m["amount"] = (qlonglong)o["amount"].toDouble();
            m["desc"] = o["description"].toString();
            m["time"] = o["created_at"].toString();
            m["balanceAfter"] = (quint64)o["balance_after"].toDouble();
            list.append(m);
        }
        emit transactionsReady(list);
    });
}

void ApiClient::fetchBenefits() {
    get("/api/benefits/available", {}, [this](int s, QByteArray r) {
        if (s != 200) return;
        QVariantList list;
        QJsonArray arr = QJsonDocument::fromJson(r).object()["benefits"].toArray();
        for (auto v : arr) {
            QJsonObject o = v.toObject();
            QVariantMap m;
            m["type"] = o["type"].toString();
            m["amount"] = (quint64)o["amount"].toDouble();
            m["description"] = o["description"].toString();
            list.append(m);
        }
        emit benefitsReady(list);
    });
}

void ApiClient::checkBenefits() {
    QVariantMap p; p["email"] = m_email;
    get("/api/benefits/check", p, [this](int s, QByteArray r) {
        if (s != 200) return;
        QStringList claimed;
        QJsonArray arr = QJsonDocument::fromJson(r).object()["claimed"].toArray();
        for (auto v : arr) claimed.append(v.toString());
        emit benefitsChecked(claimed);
    });
}

void ApiClient::fetchHotListings(int limit) {
    QVariantMap p; p["limit"] = QString::number(limit);
    get("/api/listings/hot", p, [this](int s, QByteArray r) {
        if (s != 200) return;
        QJsonArray arr = QJsonDocument::fromJson(r).object()["listings"].toArray();
        QVariantList result;
        for (auto v : arr) {
            auto l = v.toObject(); auto a = l["asset"].toObject();
            auto pc = l["pricing"].toObject(); auto sl = l["seller"].toObject();
            QVariantMap m;
            m["listingId"] = l["listing_id"].isString()
                ? l["listing_id"].toString()
                : QString::number((qint64)l["listing_id"].toDouble(), 'f', 0);
            m["name"]     = a["name"].toString();
            m["type"]     = a["type"].toString();
            m["desc"]     = a["description"].toString();
            m["oncePrice"]= pc["once_price"].toDouble();
            m["subPrice"] = pc["sub_price"].toDouble();
            m["subDuration"] = pc["sub_duration_days"].toInt(30);
            m["subCount"] = l["sub_count"].toInt();
            m["author"]   = sl["name"].toString();
            m["sellerId"] = sl["id"].isString()
                ? sl["id"].toString()
                : QString::number((qint64)sl["id"].toDouble(), 'f', 0);
            result.append(m);
        }
        emit hotListingsReady(result);
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
            QString latest  = o["latest_version"].toString();
            QString curVer  = "1.0.0"; // 客户端自身版本

            auto compareVer = [](const QString &a, const QString &b) -> int {
                auto al = a.split('.'), bl = b.split('.');
                for (int i = 0; i < qMax(al.size(), bl.size()); ++i) {
                    int av = i < al.size() ? al[i].toInt() : 0;
                    int bv = i < bl.size() ? bl[i].toInt() : 0;
                    if (av != bv) return av - bv;
                }
                return 0;
            };

            bool forceUpdate = o["force_update"].toBool();
            QVariantMap info;
            info["hasUpdate"]   = compareVer(latest, curVer) > 0;
            info["forceUpdate"] = forceUpdate;
            info["currentVer"]  = curVer;
            info["latestVer"]   = latest;
            info["githubUrl"]   = o["github_url"].toString();
            info["mirrorUrl"]   = o["mirror_url"].toString();
            info["changelog"]   = o["changelog"].toString();
            emit updateCheckFinished(info);
        } else {
            emit updateCheckFinished({});
        }
    });
}

// ── 拉取 Marketplace 上架列表 ───────────────────────
void ApiClient::fetchListings(const QString &type, const QString &search, int page) {
    QVariantMap p;
    if (!type.isEmpty())   p["type"] = type;
    if (!search.isEmpty()) p["q"]    = search;
    p["page"] = QString::number(page);
    p["size"] = "50";

    get("/api/listings", p, [this](int s, QByteArray r) {
        if (s != 200 || !m_marketModel) return;
        QJsonObject obj  = QJsonDocument::fromJson(r).object();
        QJsonArray  arr  = obj["listings"].toArray();
        QJsonDocument doc(arr);
        m_marketModel->loadFromJson(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    });
}

// ── 拉取单个 listing 最新数据（购买前验证）─────────────
void ApiClient::fetchListingDetail(const QString &listingId, const QVariantMap &cached) {
    QVariantMap p; p["id"] = listingId;
    get("/api/listings/detail", p, [this, cached](int s, QByteArray r) {
        if (s != 200) {
            emit listingDetailFetched({}, cached);
            return;
        }
        QJsonObject obj = QJsonDocument::fromJson(r).object();
        QJsonObject l  = obj["listing"].toObject();
        QJsonObject a  = l["asset"].toObject();
        QJsonObject pr = l["pricing"].toObject();
        QJsonObject sl = l["seller"].toObject();
        QVariantMap latest;
        latest["name"]         = a["name"].toString();
        latest["type"]         = a["type"].toString();
        latest["desc"]         = a["description"].toString();
        latest["version"]      = a["version"].toString();
        latest["author"]       = sl["name"].toString();
        latest["oncePrice"]    = pr["once_price"].toDouble();
        latest["subPrice"]     = pr["sub_price"].toDouble();
        latest["subDuration"]  = pr["sub_duration_days"].toInt(30);
        latest["listingId"]    = l["listing_id"].toString();
        latest["status"]       = l["status"].toString();
        emit listingDetailFetched(latest, cached);
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
