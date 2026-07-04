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
        QByteArray data = s->readAll();
        QString req = QString::fromUtf8(data);
        auto dec = [](const QString &v) { return QUrl::fromPercentEncoding(v.toUtf8()); };

        // Parse tokens from POST body or query string (POST preferred: no browser history leak)
        auto extractParam = [&](const QString &name) -> QString {
            // Try POST body first
            int bodyStart = req.indexOf("\r\n\r\n");
            if (bodyStart >= 0) {
                QString body = req.mid(bodyStart + 4);
                QUrlQuery postQuery(body);
                QString v = postQuery.queryItemValue(name);
                if (!v.isEmpty()) return dec(v);
            }
            // Fallback to query string (legacy / custom URI scheme)
            int qs = req.indexOf('?');
            if (qs >= 0) {
                int sp = req.indexOf(' ', qs);
                if (sp > qs) {
                    QUrlQuery q(req.mid(qs + 1, sp - qs - 1));
                    return dec(q.queryItemValue(name));
                }
            }
            return {};
        };

        // Validate we have a real request
        if (!req.startsWith("GET ") && !req.startsWith("POST ")) {
            s->deleteLater();
            return;
        }

        // Disconnect readyRead to prevent duplicate processing
        disconnect(s, &QTcpSocket::readyRead, this, nullptr);

        QString mode = extractParam("mode");
        QString json = QString(R"({"access_token":"%1","refresh_token":"%2","email":"%3","username":"%4","uid":"%5","avatar":"%6","mode":"%7"})")
            .arg(extractParam("access_token"),
                 extractParam("refresh_token"),
                 extractParam("email"),
                 extractParam("username"),
                 extractParam("uid"),
                 extractParam("avatar"),
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
        QByteArray resp = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n"
                          "Referrer-Policy: no-referrer\r\n"
                          "Connection: close\r\n\r\n"
                          "<!DOCTYPE html><html><head><script>history.replaceState({},'','/');</script></head>"
                          "<body style='background:#0d1117;color:#e6edf3;"
                          "display:flex;align-items:center;justify-content:center;height:100vh;margin:0'>"
                          "<h2>授权成功，请返回应用</h2></body></html>";
        s->write(resp); s->flush(); s->disconnectFromHost();
        s->deleteLater();
    });
}
