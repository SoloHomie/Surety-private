#include "SubscriptionStore.h"
#include "CryptoHelper.h"
#include "../system/FileHelper.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>

SubscriptionStore *SubscriptionStore::instance() { static SubscriptionStore s; return &s; }

SubscriptionStore::SubscriptionStore(QObject *parent) : QObject(parent) {
    QDir().mkpath(cachePath());
}

QString SubscriptionStore::cachePath() const {
    return FileHelper::instance()->subscriptionsPath();
}

QString SubscriptionStore::_filePath(const QString &assetId) const {
    return cachePath() + "/" + assetId + ".surety";
}

bool SubscriptionStore::save(const QString &assetId, const QVariantMap &data) {
    return CryptoHelper::instance()->saveSuretyFile(_filePath(assetId), data);
}

QVariantMap SubscriptionStore::load(const QString &assetId) {
    return CryptoHelper::instance()->loadSuretyFile(_filePath(assetId));
}

bool SubscriptionStore::remove(const QString &assetId) {
    return QFile::remove(_filePath(assetId));
}

QStringList SubscriptionStore::cachedIds() const {
    QStringList ids;
    QDir dir(cachePath());
    auto files = dir.entryList({"*.surety"}, QDir::Files, QDir::Time);
    for (auto &f : files) {
        f.chop(7); // remove ".surety"
        ids.append(f);
    }
    return ids;
}

bool SubscriptionStore::hasCache(const QString &assetId) const {
    return QFileInfo::exists(_filePath(assetId));
}
