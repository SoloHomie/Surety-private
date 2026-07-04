#pragma once
#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QUrlQuery>

class OAuthServer : public QObject {
    Q_OBJECT
    Q_PROPERTY(int port READ port NOTIFY portChanged)
public:
    explicit OAuthServer(QObject *p = nullptr);
    int port() const { return m_port; }
    Q_INVOKABLE int start();
    Q_INVOKABLE void stop();
signals:
    void portChanged();
    void oauthReceived(const QString &json);
private:
    void onConnection();
    QTcpServer m_server;
    int m_port = 0;
    qint64 m_lastEmitMs = 0;  // 防重入：上次 emit 时间戳
};
