#pragma once
#include <QObject>

class AssetService : public QObject {
    Q_OBJECT
public:
    static AssetService* instance();

    Q_INVOKABLE void listAssets(const QString &email, const QString &type);
    Q_INVOKABLE void createAsset(const QString &email, const QString &type,
                                  const QString &name, const QString &desc,
                                  const QString &version);
    /// 更新已有资产（修改后保存）
    Q_INVOKABLE void updateAsset(const QString &email, const QString &assetId,
                                  const QString &type, const QString &name,
                                  const QString &desc, const QString &version);
    Q_INVOKABLE void listPricing(const QString &assetId);
    Q_INVOKABLE void addPricing(const QString &assetId, const QString &model,
                                 const QString &price, const QString &durationDays);
    Q_INVOKABLE void listSubscriptions(const QString &email);

signals:
    void assetsLoaded(const QString &json);
    void subscriptionsLoaded(const QString &json);
    void pricingLoaded(const QString &json);
    void assetCreated(bool ok, const QString &assetId, const QString &msg);
    void assetUpdated(bool ok, const QString &msg);
    void pricingAdded(bool ok, const QString &msg);
    void errorOccurred(const QString &operation, const QString &message);

private:
    explicit AssetService(QObject *parent = nullptr) : QObject(parent) {}
    static QString arrToJson(const QJsonArray &arr);
};
