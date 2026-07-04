#pragma once
#include <QAbstractListModel>
#include <QVariantMap>
#include <QJsonArray>

class MarketListModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles { MName=Qt::UserRole+1, MType, MColor, MDesc, MAuthor,
                 MOncePrice, MSubPrice, MSubDuration,
                 MFav, MListingId, MVersion, MSellerId };
    explicit MarketListModel(QObject *p = nullptr) : QAbstractListModel(p) {}
    QHash<int,QByteArray> roleNames() const override;
    int rowCount(const QModelIndex & = {}) const override;
    QVariant data(const QModelIndex &idx, int role) const override;
    Q_INVOKABLE void loadFromJson(const QString &json);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE void prependItem(const QVariantMap &item);
private:
    QList<QVariantMap> m_data;
};
