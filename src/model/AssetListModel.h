#pragma once
#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonDocument>
#include <QVariantMap>

class AssetListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    enum Roles { Name=Qt::UserRole+1, Type, Code, Version, Author, HasSub, AssetId, Desc, Props, Quick };

    explicit AssetListModel(QObject *p = nullptr) : QAbstractListModel(p) {}

    QHash<int,QByteArray> roleNames() const override;
    int rowCount(const QModelIndex & = {}) const override;
    QVariant data(const QModelIndex &idx, int role) const override;

    int count() const { return m_data.size(); }

    Q_INVOKABLE void loadFromJson(const QString &json, bool isSub = false);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int row) const;

    /// 根据 assetId 更新一行中的若干字段，发射 dataChanged
    Q_INVOKABLE void updateItem(const QString &assetId, const QVariantMap &fields);
    /// 根据 assetId 删除一行
    Q_INVOKABLE void removeItem(const QString &assetId);
    /// 统计某 boolean 字段为指定值的行数，如 countByField("quick", true)
    Q_INVOKABLE int countByField(const QString &field, bool value) const;

signals:
    void countChanged();

private:
    int findRow(const QString &assetId) const;
    QList<QVariantMap> m_data;
};
