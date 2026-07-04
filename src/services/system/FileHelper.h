#pragma once
#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QThread>

// 文件操作 + 可配置存储路径（异步迁移）
class FileHelper : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isMigrating READ isMigrating NOTIFY isMigratingChanged)
public:
    static FileHelper *instance();

    Q_INVOKABLE QStringList listDir(const QString &path);
    Q_INVOKABLE QString readFile(const QString &path);
    Q_INVOKABLE bool deleteFile(const QString &path);

    Q_INVOKABLE QString dataPath();
    Q_INVOKABLE QString defaultDataPath();
    Q_INVOKABLE QString draftsPath();
    Q_INVOKABLE QString personalPath();
    Q_INVOKABLE QString subscriptionsPath();

    // 异步设置路径（不阻塞 UI），完成后发 dataPathChanged
    Q_INVOKABLE void setDataPath(const QString &newPath);
    bool isMigrating() const { return m_migrating; }

    Q_INVOKABLE QVariantList scanAllDrafts();
    Q_INVOKABLE bool moveToPersonal(const QString &filePath, const QString &assetType);

signals:
    void dataPathChanged();
    void migrateProgress(int percent);
    void migrateFinished(bool ok, const QString &message);
    void isMigratingChanged();

private:
    explicit FileHelper(QObject *parent = nullptr) : QObject(parent) {}
    void ensureDirs();
    void applyNewPath(const QString &newPath);

    QString m_dataPath;
    bool    m_pathInitialized = false;
    bool    m_migrating = false;
    QThread *m_thread = nullptr;
};
