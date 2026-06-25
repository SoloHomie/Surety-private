#pragma once
#include <QAbstractListModel>
#include <QVariantMap>
#include <QJsonArray>

class MarketListModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles { MName=Qt::UserRole+1, MType, MColor, MDesc, MAuthor, MPrice,
                 MFav, MListingId, MPricingModel, MDuration };
    explicit MarketListModel(QObject *p = nullptr) : QAbstractListModel(p) {}
    QHash<int,QByteArray> roleNames() const override;
    int rowCount(const QModelIndex & = {}) const override;
    QVariant data(const QModelIndex &idx, int role) const override;
    Q_INVOKABLE void loadFromJson(const QString &json);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int row) const;
private:
    QList<QVariantMap> m_data;
};
