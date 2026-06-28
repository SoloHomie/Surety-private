#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <functional>

using ApiCallback = std::function<void(int, QByteArray)>;

class AssetListModel;

// 全局 HTTP 客户端 + 认证状态 + 本地统计
class ApiClient : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString accessToken  READ accessToken  NOTIFY authChanged)
    Q_PROPERTY(QString refreshToken READ refreshToken NOTIFY authChanged)
    Q_PROPERTY(QString email        READ email        NOTIFY authChanged)
    Q_PROPERTY(QString username     READ username     NOTIFY authChanged)
    Q_PROPERTY(QString avatarUrl    READ avatarUrl    NOTIFY authChanged)
    Q_PROPERTY(QString uid          READ uid          NOTIFY authChanged)
    Q_PROPERTY(bool    isLoggedIn   READ isLoggedIn   NOTIFY authChanged)
    Q_PROPERTY(QString provider     READ provider     NOTIFY authChanged)

    // ── 本地统计（从 model 计算）──
    Q_PROPERTY(int assetCount  READ assetCount  NOTIFY assetCountChanged)
    Q_PROPERTY(int listedCount READ listedCount NOTIFY listedCountChanged)
    Q_PROPERTY(int subCount    READ subCount    NOTIFY subCountChanged)

    Q_PROPERTY(QVariantList devLogs    READ devLogs    NOTIFY devLogsChanged)
    Q_PROPERTY(QVariantList oauthLinks READ oauthLinks NOTIFY oauthLinksChanged)

public:
    static ApiClient* instance();

    QString accessToken()  const { return m_accessToken;  }
    QString refreshToken() const { return m_refreshToken; }
    QString email()        const { return m_email;        }
    QString username()     const { return m_username;     }
    QString avatarUrl()    const { return m_avatarUrl;    }
    QString uid()          const { return m_uid;          }
    bool    isLoggedIn()   const { return !m_accessToken.isEmpty(); }
    QString provider()     const { return m_provider; }

    int  assetCount()  const { return m_assetCount; }
    int  listedCount() const { return m_listedCount; }
    int  subCount()    const { return m_subCount; }

    void get(const QString &path, const QVariantMap &params, ApiCallback callback);
    void post(const QString &path, const QVariantMap &body, ApiCallback callback);
    Q_INVOKABLE void setAuth(const QString &json);
    Q_INVOKABLE void clearAuth();
    Q_INVOKABLE void saveSession();
    Q_INVOKABLE void loadSession();
    Q_INVOKABLE void tryAutoLogin();

    /// 从服务器拉取用户统计（登录后初始化用）
    Q_INVOKABLE void fetchStats();
    /// 从 AssetModel / SubModel 重新计算本地统计（客户端操作后乐观更新用）
    Q_INVOKABLE void updateLocalStats();
    /// 设置关联的 model（由 main.cpp 注入）
    void setAssetModel(AssetListModel *m) { m_assetModel = m; }
    void setSubModel(AssetListModel *m)   { m_subModel   = m; }

    Q_INVOKABLE void fetchDevLogs();
    Q_INVOKABLE void fetchOAuthLinks();
    Q_INVOKABLE void unlinkOAuth(const QString &provider);
    QVariantList oauthLinks() const { return m_oauthLinks; }

    /// 检查更新
    Q_INVOKABLE void checkUpdate();

    /// 快速上架/下架 — 成功后更新 model 的 quick 字段
    Q_INVOKABLE void quickListAsset(const QString &assetId);
    Q_INVOKABLE void quickUnlistAsset(const QString &assetId);

    QVariantList devLogs() const { return m_devLogs; }

signals:
    void authChanged();
    void autoLoginFinished(bool ok);
    void assetCountChanged();
    void listedCountChanged();
    void subCountChanged();
    void devLogsChanged();
    void oauthLinksChanged();
    void updateCheckFinished(const QVariantMap &info);

private:
    explicit ApiClient(QObject *parent = nullptr);
    void setupRequest(QNetworkRequest &req);

    QNetworkAccessManager m_nam;
    QString m_baseUrl = "http://localhost:8920";
    QString m_accessToken, m_refreshToken, m_uid, m_email, m_username, m_avatarUrl, m_provider;

    int m_assetCount = 0, m_listedCount = 0, m_subCount = 0;
    QVariantList m_devLogs;
    QVariantList m_oauthLinks;

    AssetListModel *m_assetModel = nullptr;
    AssetListModel *m_subModel   = nullptr;
};
