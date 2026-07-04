#include "AssetWatcher.h"
#include "../system/FileHelper.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QRegularExpression>

AssetWatcher *AssetWatcher::instance() {
    static AssetWatcher s;
    return &s;
}

AssetWatcher::AssetWatcher(QObject *parent)
    : QObject(parent)
{
    _watcher = new QFileSystemWatcher(this);
    connect(_watcher, &QFileSystemWatcher::directoryChanged, this, [this]() {
        // 防抖：300ms 内多次触发只扫描一次
        if (!_debounce) {
            _debounce = new QTimer(this);
            _debounce->setSingleShot(true);
            _debounce->setInterval(300);
            connect(_debounce, &QTimer::timeout, this, &AssetWatcher::_scanDir);
        }
        _debounce->start();
    });

    // 监控路径: {dataPath}/drafts，路径变化时重新绑定
    auto *fh = FileHelper::instance();
    setWatchPath(fh->draftsPath());
    connect(fh, &FileHelper::dataPathChanged, this, [this]() {
        setWatchPath(FileHelper::instance()->draftsPath());
    });
}

void AssetWatcher::stopWatching() {
    auto dirs = _watcher->directories();
    if (!dirs.isEmpty())
        _watcher->removePaths(dirs);
}

void AssetWatcher::setWatchPath(const QString &path) {
    if (path == _watchPath) return;

    // 移除旧路径
    if (!_watchPath.isEmpty()) {
        for (auto &d : _watcher->directories())
            _watcher->removePath(d);
    }

    _watchPath = path;

    // 创建类型子目录并添加到监视
    for (auto &td : TYPE_DIRS) {
        QString sub = _watchPath + "/" + td;
        QDir().mkpath(sub);
        _watcher->addPath(sub);
    }

    emit watchPathChanged();
    _scanDir();
}

QVariantList AssetWatcher::scan() {
    _scanDir();
    return _drafts;
}

void AssetWatcher::_scanDir() {
    QVariantList newDrafts;

    for (auto &td : TYPE_DIRS) {
        QDir dir(_watchPath + "/" + td);
        auto files = dir.entryList(QDir::Files, QDir::Time);
        for (const auto &f : files) {
            QString fullPath = dir.absoluteFilePath(f);

            // 跳过已存在的
            bool found = false;
            for (auto &d : _drafts) {
                if (d.toMap().value("filePath").toString() == fullPath)
                    { found = true; break; }
            }
            if (found) continue;

            QVariantMap draft = _parseFile(fullPath, td);
            if (draft.isEmpty()) continue;
            draft["filePath"] = fullPath;
            newDrafts.append(draft);
            emit draftDiscovered(draft);
        }
    }

    if (!newDrafts.isEmpty()) {
        _drafts.append(newDrafts);
        emit draftsChanged();
    }
}

// 解析各种注释格式的 frontmatter
static bool parseFrontmatter(const QString &text, const QString &prefix,
                              QString &frontmatter, QString &content) {
    QStringList lines = text.split('\n');
    if (lines.isEmpty()) return false;
    // 第一行必须匹配注释前缀 + "---"
    if (!lines[0].trimmed().startsWith(prefix + "---")) return false;
    frontmatter.clear();
    int i = 1;
    for (; i < lines.size(); ++i) {
        QString t = lines[i].trimmed();
        if (t.startsWith(prefix + "---")) break;
        if (t.startsWith(prefix))
            frontmatter += t.mid(prefix.length()) + "\n";
    }
    if (i >= lines.size()) return false; // 找不到结束标记
    QStringList rest = lines.mid(i + 1);
    content = rest.join('\n').trimmed();
    return !frontmatter.isEmpty();
}

QVariantMap AssetWatcher::_parseFile(const QString &filePath, const QString &typeHint) {
    QFile f(filePath);
    if (!f.open(QIODevice::ReadOnly)) return {};
    QString text = QString::fromUtf8(f.readAll());
    f.close();

    QVariantMap m;
    QString content = text;
    QString fm;

    // 尝试多种注释格式的 frontmatter
    bool hasFM = false;
    if      (text.startsWith("---"))       hasFM = parseFrontmatter(text, "",     fm, content);
    else if (text.startsWith("# ---"))      hasFM = parseFrontmatter(text, "# ",   fm, content);
    else if (text.startsWith("// ---"))     hasFM = parseFrontmatter(text, "// ",  fm, content);
    else if (text.startsWith("/* ---"))     hasFM = parseFrontmatter(text, "/* ",  fm, content);

    if (hasFM) {
        for (auto &line : fm.split('\n')) {
            int colon = line.indexOf(':');
            if (colon < 1) continue;
            QString key = line.left(colon).trimmed();
            QString val = line.mid(colon + 1).trimmed();
            if ((val.startsWith('"') && val.endsWith('"')) ||
                (val.startsWith('\'') && val.endsWith('\'')))
                val = val.mid(1, val.length() - 2);
            m[key] = val;
        }
    }

    // frontmatter 没写 type → 用子目录名推断
    if (!m.contains("type") && !typeHint.isEmpty()) {
        // typeHint 是复数目录名 "skills"→"Skill", "scripts"→"Script"...
        QString singular = typeHint;
        if (singular.endsWith('s'))
            singular.chop(1);
        singular[0] = singular[0].toUpper();
        m["type"] = singular;
    }

    // 无 frontmatter → 从文件和内容推断
    if (!m.contains("type")) {
        QString ext  = QFileInfo(filePath).suffix().toLower();
        QString lower = text.toLower();
        if      (ext == "py" || ext == "sh" || ext == "js" || ext == "ts" || ext == "ps1") m["type"] = "Script";
        else if (ext == "md" || ext == "txt")  m["type"] = "Prompt";
        else if (ext == "yaml" || ext == "yml" || ext == "toml" || ext == "json") m["type"] = "Tool";
        else if (lower.contains("skill") || lower.contains("指令") || lower.contains("角色")) m["type"] = "Skill";
        else if (lower.contains("script") || lower.contains("脚本") || lower.contains("#!/")) m["type"] = "Script";
        else if (lower.contains("prompt") || lower.contains("提示"))  m["type"] = "Prompt";
        else if (lower.contains("workflow") || lower.contains("流程")) m["type"] = "Workflow";
        else    m["type"] = "Script"; // 兜底：有代码倾向
    }
    if (!m.contains("name")) {
        QRegularExpression re("^#\\s+(.+)$", QRegularExpression::MultilineOption);
        auto match = re.match(text);
        m["name"] = match.hasMatch() ? match.captured(1).trimmed()
                    : QFileInfo(filePath).completeBaseName();
    }
    if (!m.contains("description")) {
        QString body = content;
        body.remove(QRegularExpression("^#.*\\n?", QRegularExpression::MultilineOption));
        body.remove(QRegularExpression("^.*---.*\\n?", QRegularExpression::MultilineOption));
        for (auto &p : body.trimmed().split('\n')) {
            QString t = p.trimmed();
            if (!t.isEmpty() && !t.startsWith('#') && !t.startsWith("//") && !t.startsWith("/*")) {
                m["description"] = t.left(80); break;
            }
        }
    }
    if (!m.contains("version")) m["version"] = "1.0";
    m["content"] = content;
    if (m["name"].toString().isEmpty()) return {};
    return m;
}

QVariantMap AssetWatcher::takeDraft(const QString &filePath) {
    for (int i = 0; i < _drafts.size(); ++i) {
        auto m = _drafts[i].toMap();
        if (m.value("filePath").toString() == filePath) {
            _drafts.removeAt(i);
            emit draftsChanged();
            return m;
        }
    }
    return {};
}

void AssetWatcher::markProcessed(const QString &filePath) {
    QFile::remove(filePath);
}
