#pragma once
#include <QObject>
#include <QVariantMap>
#include <QStringList>

// =========================================================================
//  SubscriptionStore — 订阅资产本地加密缓存
//  文件: %LOCALAPPDATA%/Surety/subscriptions/{asset_id}.surety
//  使用 CryptoHelper (DPAPI) 加密，与当前 Windows 用户绑定
// =========================================================================

class SubscriptionStore : public QObject {
    Q_OBJECT
public:
    static SubscriptionStore *instance();
    Q_INVOKABLE QString cachePath() const;

    // 保存订阅资产（加密写入）
    Q_INVOKABLE bool save(const QString &assetId, const QVariantMap &data);
    // 加载订阅资产（解密读取）
    Q_INVOKABLE QVariantMap load(const QString &assetId);
    // 删除缓存
    Q_INVOKABLE bool remove(const QString &assetId);
    // 已缓存的资产 ID 列表
    Q_INVOKABLE QStringList cachedIds() const;
    // 检查是否已缓存
    Q_INVOKABLE bool hasCache(const QString &assetId) const;

private:
    explicit SubscriptionStore(QObject *parent = nullptr);
    QString _filePath(const QString &assetId) const;
};
