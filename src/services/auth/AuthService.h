#pragma once
#include <QObject>

class AuthService : public QObject {
    Q_OBJECT
public:
    static AuthService* instance();

    Q_INVOKABLE void sendCode(const QString &email, const QString &purpose);
    Q_INVOKABLE void registerUser(const QString &email, const QString &password, const QString &code);
    Q_INVOKABLE void login(const QString &email, const QString &password, bool rememberMe = false);
    Q_INVOKABLE void resetPassword(const QString &email, const QString &code, const QString &newPassword);
    Q_INVOKABLE void getOAuthUrl(const QString &provider, int port);
    Q_INVOKABLE void getOAuthBindUrl(const QString &provider, int port);
    Q_INVOKABLE void logout();

signals:
    void sendCodeResult(bool ok, const QString &msg);
    void registerResult(bool ok, const QString &msg);
    void loginResult(bool ok, const QString &msg);
    void resetPasswordResult(bool ok, const QString &msg);
    void oauthUrlReady(const QString &url);
    void loggedOut();

private:
    explicit AuthService(QObject *parent = nullptr) : QObject(parent) {}
};
