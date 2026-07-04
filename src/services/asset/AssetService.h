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
    Q_INVOKABLE void createAssetFull(const QString &email, const QString &type,
                                      const QString &name, const QString &desc,
                                      const QString &version,
                                      const QString &oncePrice,
                                      const QString &subPrice,
                                      const QString &subDuration);
    Q_INVOKABLE void updateAsset(const QString &email, const QString &assetId,
                                  const QString &type, const QString &name,
                                  const QString &desc, const QString &version);
    Q_INVOKABLE void updateAssetFull(const QString &email, const QString &assetId,
                                      const QString &type, const QString &name,
                                      const QString &desc, const QString &version,
                                      const QString &oncePrice,
                                      const QString &subPrice,
                                      const QString &subDuration);
    Q_INVOKABLE void deleteAsset(const QString &email, const QString &assetId);
    Q_INVOKABLE void listSubscriptions(const QString &email);

signals:
    void assetsLoaded(const QString &json);
    void subscriptionsLoaded(const QString &json);
    void assetCreated(bool ok, const QString &assetId, const QString &msg);
    void assetUpdated(bool ok, const QString &msg);
    void errorOccurred(const QString &operation, const QString &message);

private:
    explicit AssetService(QObject *parent = nullptr) : QObject(parent) {}
    static QString arrToJson(const QJsonArray &arr);
};
