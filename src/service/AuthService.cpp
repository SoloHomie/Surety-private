#include "AuthService.h"
#include "../network/ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>

AuthService* AuthService::instance() { static AuthService s; return &s; }

static QString msg(const QByteArray &r) {
    return QJsonDocument::fromJson(r).object()["message"].toString();
}

void AuthService::sendCode(const QString &e, const QString &p) {
    QVariantMap b; b["email"]=e; b["purpose"]=p;
    ApiClient::instance()->post("/api/auth/send-code", b, [this](int s, QByteArray r) {
        emit sendCodeResult(s==200, msg(r));
    });
}
void AuthService::registerUser(const QString &e, const QString &p, const QString &c) {
    QVariantMap b; b["email"]=e; b["password"]=p; b["code"]=c;
    ApiClient::instance()->post("/api/auth/register", b, [this](int s, QByteArray r) {
        emit registerResult(s==200, msg(r));
    });
}
void AuthService::login(const QString &e, const QString &p, bool rememberMe) {
    QVariantMap b; b["email"]=e; b["password"]=p;
    ApiClient::instance()->post("/api/auth/login", b, [this, rememberMe](int s, QByteArray r) {
        if (s == 200) {
            ApiClient::instance()->setAuth(QString::fromUtf8(r));
            if (rememberMe) ApiClient::instance()->saveSession();
        }
        emit loginResult(s==200, msg(r));
    });
}
void AuthService::resetPassword(const QString &e, const QString &c, const QString &np) {
    QVariantMap b; b["email"]=e; b["code"]=c; b["newPassword"]=np;
    ApiClient::instance()->post("/api/auth/reset-password", b, [this](int s, QByteArray r) {
        emit resetPasswordResult(s==200, msg(r));
    });
}
void AuthService::getOAuthUrl(const QString &prov, int port) {
    QVariantMap p; if(port>0) p["cbport"]=port;
    ApiClient::instance()->get("/api/auth/oauth/"+prov, p, [this](int s, QByteArray r) {
        QString url;
        if(s==200) url=QJsonDocument::fromJson(r).object()["oauth_url"].toString();
        emit oauthUrlReady(url);
    });
}
void AuthService::getOAuthBindUrl(const QString &prov, int port) {
    QVariantMap p; if(port>0) p["cbport"]=port;
    p["bind_uid"] = ApiClient::instance()->uid();
    ApiClient::instance()->get("/api/auth/oauth/"+prov, p, [this](int s, QByteArray r) {
        QString url;
        if(s==200) url=QJsonDocument::fromJson(r).object()["oauth_url"].toString();
        emit oauthUrlReady(url);
    });
}
void AuthService::logout() {
    QVariantMap b; b["refresh_token"]=ApiClient::instance()->refreshToken();
    ApiClient::instance()->post("/api/auth/logout", b, [this](int, QByteArray) {
        ApiClient::instance()->clearAuth();
        emit loggedOut();
    });
}
