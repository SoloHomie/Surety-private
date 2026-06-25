#include "OAuthServer.h"
#include <QUrl>
#include <chrono>
#include <iostream>

OAuthServer::OAuthServer(QObject *p) : QObject(p) {
    connect(&m_server, &QTcpServer::newConnection, this, &OAuthServer::onConnection);
}

int OAuthServer::start() {
    if (m_server.isListening()) return m_port;
    m_server.listen(QHostAddress::LocalHost, 0);
    m_port = m_server.serverPort();
    std::cerr << "OAuthServer listening on port: " << m_port << std::endl;
    emit portChanged();
    return m_port;
}

void OAuthServer::stop() { m_server.close(); }

void OAuthServer::onConnection() {
    auto *s = m_server.nextPendingConnection();
    if (!s) return;
    std::cerr << "OAuthServer: connection received" << std::endl;
    connect(s, &QTcpSocket::readyRead, this, [this, s]() {
        std::cerr << "OAuthServer: data received" << std::endl;
        QString req = QString::fromUtf8(s->readAll());
        int qs = req.indexOf('?'), sp = req.indexOf(' ', qs);
        if (qs < 0 || sp < qs) {
            // qs >= 0 && sp < qs: TCP 分片还没收完，继续等下一次 readyRead
            // qs < 0: 无效请求（如 /favicon.ico），直接释放
            if (qs < 0) s->deleteLater();
            return;
        }
        // 解析成功，立即断开 readyRead 防止重复触发
        disconnect(s, &QTcpSocket::readyRead, this, nullptr);
        QUrlQuery q(req.mid(qs + 1, sp - qs - 1));
        // QUrlQuery 在 Qt6 默认不会完全解码百分号编码，显式解码所有参数
        auto dec = [](const QString &v) { return QUrl::fromPercentEncoding(v.toUtf8()); };
        QString mode = dec(q.queryItemValue("mode"));
        QString json = QString(R"({"access_token":"%1","refresh_token":"%2","email":"%3","username":"%4","uid":"%5","avatar":"%6","mode":"%7"})")
            .arg(dec(q.queryItemValue("access_token")),
                 dec(q.queryItemValue("refresh_token")),
                 dec(q.queryItemValue("email")),
                 dec(q.queryItemValue("username")),
                 dec(q.queryItemValue("uid")),
                 dec(q.queryItemValue("avatar")),
                 mode);
        std::cerr << "OAuthServer: emitting oauthReceived" << std::endl;
        // 1 秒防重入：浏览器可能建立多条 TCP 连接（预连接/重试）
        auto now = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now().time_since_epoch()).count();
        if (now - m_lastEmitMs < 1000) {
            std::cerr << "OAuthServer: suppressed duplicate emission" << std::endl;
            s->deleteLater();
            return;
        }
        m_lastEmitMs = now;
        emit oauthReceived(json);
        QByteArray resp = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nConnection: close\r\n\r\n"
                          "<!DOCTYPE html><html><body style='background:#0d1117;color:#e6edf3;"
                          "display:flex;align-items:center;justify-content:center;height:100vh;margin:0'>"
                          "<h2>授权成功，请返回应用</h2></body></html>";
        s->write(resp); s->flush(); s->disconnectFromHost();
        s->deleteLater();
    });
}
