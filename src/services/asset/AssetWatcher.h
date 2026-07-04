#pragma once
#include <QObject>
#include <QFileSystemWatcher>
#include <QDir>
#include <QVariantList>
#include <QVariantMap>
#include <QTimer>

// =========================================================================
//  AssetWatcher — 监视本地文件夹，自动发现 Agent 产出的资产草稿
//  目录结构: %APPDATA%/Surety/assets/{skills,scripts,prompts,tools,workflows}/
//  文件格式: 任意文本文件，支持 YAML frontmatter
// =========================================================================

class AssetWatcher : public QObject
{
    Q_OBJECT
public:
    static AssetWatcher *instance();

    explicit AssetWatcher(QObject *parent = nullptr);

    Q_PROPERTY(QString watchPath READ watchPath WRITE setWatchPath NOTIFY watchPathChanged)
    Q_PROPERTY(QVariantList drafts READ drafts NOTIFY draftsChanged)

    QString     watchPath() const { return _watchPath; }
    QVariantList drafts()  const { return _drafts; }

    void setWatchPath(const QString &path);
    void stopWatching();

    // 扫描文件夹，返回新发现的草稿列表
    Q_INVOKABLE QVariantList scan();
    // 导入指定草稿（返回解析后的 QVariantMap，同时从列表移除）
    Q_INVOKABLE QVariantMap takeDraft(const QString &filePath);
    // 标记已处理（删除文件）
    Q_INVOKABLE void    markProcessed(const QString &filePath);

signals:
    void watchPathChanged();
    void draftsChanged();
    void draftDiscovered(const QVariantMap &draft);

private:
    void _scanDir();
    static QVariantMap _parseFile(const QString &filePath, const QString &typeHint = {});

    QFileSystemWatcher *_watcher = nullptr;
    QTimer              *_debounce = nullptr;
    QString              _watchPath;
    QVariantList         _drafts;   // [{filePath, type, name, description, version, content}]

    static inline const QStringList TYPE_DIRS = {"skills", "scripts", "prompts", "tools", "workflows"};
};
