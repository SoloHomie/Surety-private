#include "FileHelper.h"
#include "MigrationWorker.h"
#include "../asset/AssetWatcher.h"
#include "UserSettings.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QStandardPaths>

FileHelper *FileHelper::instance() { static FileHelper s; return &s; }

void FileHelper::ensureDirs() {
    if (m_pathInitialized) return;
    m_pathInitialized = true;

    QString saved = UserSettings::instance()->value("General/dataPath").toString();
    if (!saved.isEmpty() && QDir().mkpath(saved) && QDir(saved).exists())
        m_dataPath = QDir::cleanPath(saved);
    else
        m_dataPath = defaultDataPath();

    // 确保根目录存在
    QDir().mkpath(m_dataPath);

    // 首次从旧位置迁移
    QString oldDef = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/Surety";
    if (m_dataPath == defaultDataPath() && QDir(oldDef).exists() && oldDef != m_dataPath) {
        auto copyDir = [](auto &self, const QString &src, const QString &dst) -> bool {
            QDir().mkpath(dst);
            for (auto &e : QDir(src).entryInfoList(QDir::Files|QDir::Dirs|QDir::NoDotAndDotDot)) {
                QString d = dst + "/" + e.fileName();
                if (e.isDir()) { if (!self(self, e.absoluteFilePath(), d)) return false; }
                else { if (QFile::exists(d)) QFile::remove(d); if (!QFile::copy(e.absoluteFilePath(), d)) return false; }
            }
            return true;
        };
        if (copyDir(copyDir, oldDef, m_dataPath))
            QDir(oldDef).removeRecursively();
    }

    QStringList types = {"skills","scripts","prompts","tools","workflows"};
    for (auto &t : types) {
        QDir().mkpath(m_dataPath + "/drafts/" + t);
        QDir().mkpath(m_dataPath + "/personal/" + t);
    }
    QDir().mkpath(m_dataPath + "/subscriptions");
}

QString FileHelper::defaultDataPath()   { return QCoreApplication::applicationDirPath() + "/SuretyData"; }
QString FileHelper::dataPath()          { ensureDirs(); return m_dataPath; }
QString FileHelper::draftsPath()        { return dataPath() + "/drafts"; }
QString FileHelper::personalPath()      { return dataPath() + "/personal"; }
QString FileHelper::subscriptionsPath() { return dataPath() + "/subscriptions"; }

void FileHelper::applyNewPath(const QString &newPath) {
    m_dataPath = newPath;
    UserSettings::instance()->setValue("General/dataPath", newPath);
    UserSettings::instance()->sync();
    QStringList types = {"skills","scripts","prompts","tools","workflows"};
    for (auto &t : types) {
        QDir().mkpath(m_dataPath + "/drafts/" + t);
        QDir().mkpath(m_dataPath + "/personal/" + t);
    }
    QDir().mkpath(m_dataPath + "/subscriptions");
}

void FileHelper::setDataPath(const QString &newPath) {
    QString cleanNew = QDir::cleanPath(newPath);
    QString cleanOld = QDir::cleanPath(m_dataPath);
    if (m_migrating || cleanNew.isEmpty() || cleanNew == cleanOld) return;
    QDir().mkpath(cleanNew);
    if (!QDir(cleanNew).exists()) { emit migrateFinished(false, "无法创建目录"); return; }

    QString oldPath = m_dataPath;

    // 停止监视旧路径，释放文件锁
    AssetWatcher::instance()->stopWatching();

    // 后台线程迁移
    m_migrating = true;
    emit isMigratingChanged();

    auto *worker = new MigrationWorker(oldPath, cleanNew);
    m_thread = new QThread(this);

    worker->moveToThread(m_thread);
    connect(m_thread, &QThread::started, worker, &MigrationWorker::run);
    connect(worker, &MigrationWorker::progress, this, &FileHelper::migrateProgress);
    connect(worker, &MigrationWorker::finished, this, [this, cleanNew](bool ok, QString msg) {
        if (ok) applyNewPath(cleanNew);
        m_migrating = false;
        emit isMigratingChanged();
        emit migrateFinished(ok, msg);
        emit dataPathChanged();
        m_thread->quit();
    });
    connect(m_thread, &QThread::finished, worker, &QObject::deleteLater);
    connect(m_thread, &QThread::finished, m_thread, &QObject::deleteLater);
    m_thread->start();
}

// ── 基础操作 ──
QStringList FileHelper::listDir(const QString &path) {
    return QDir(path).entryList(QDir::Files, QDir::Time);
}

QString FileHelper::readFile(const QString &path) {
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) return {};
    return QString::fromUtf8(f.readAll());
}

bool FileHelper::deleteFile(const QString &path) { return QFile::remove(path); }

bool FileHelper::moveToPersonal(const QString &filePath, const QString &assetType) {
    QString td = assetType.toLower(); if (!td.endsWith('s')) td += 's';
    QString dest = personalPath() + "/" + td;
    QDir().mkpath(dest);
    QFileInfo fi(filePath);
    QString dp = dest + "/" + fi.fileName();
    if (QFile::exists(dp)) QFile::remove(dp);
    return QFile::rename(filePath, dp);
}

// ── Frontmatter / scanAllDrafts（同上）──
static bool parseFM(const QString &t, const QString &p, QString &f, QString &c) {
    auto ls = t.split('\n'); if (ls.isEmpty() || !ls[0].trimmed().startsWith(p+"---")) return false;
    f.clear(); int i=1;
    for (;i<ls.size();++i) { auto s=ls[i].trimmed(); if(s.startsWith(p+"---")) break; if(s.startsWith(p)) f+=s.mid(p.length())+"\n"; }
    if (i>=ls.size()) return false;
    c=ls.mid(i+1).join('\n').trimmed(); return !f.isEmpty();
}
static QVariantMap parseFile(const QString &fp, const QString &th) {
    QFile f(fp); if(!f.open(QIODevice::ReadOnly)) return {};
    QString t=QString::fromUtf8(f.readAll()); f.close();
    QVariantMap m; QString c=t,fm; bool h=false;
    if      (t.startsWith("---"))   h=parseFM(t,"",fm,c);
    else if (t.startsWith("# ---"))  h=parseFM(t,"# ",fm,c);
    else if (t.startsWith("// ---")) h=parseFM(t,"// ",fm,c);
    else if (t.startsWith("/* ---")) h=parseFM(t,"/* ",fm,c);
    if(h){ for(auto &l:fm.split('\n')){ int p=l.indexOf(':'); if(p<1)continue;
        QString k=l.left(p).trimmed(),v=l.mid(p+1).trimmed();
        if((v.startsWith('"')&&v.endsWith('"'))||(v.startsWith('\'')&&v.endsWith('\''))) v=v.mid(1,v.length()-2); m[k]=v; }}
    if(!m.contains("type")&&!th.isEmpty()){ QString s=th; if(s.endsWith("s"))s.chop(1); s[0]=s[0].toUpper(); m["type"]=s; }
    if(!m.contains("type")){
        QString e=QFileInfo(fp).suffix().toLower(),l=t.toLower();
        if     (e=="py"||e=="sh"||e=="js"||e=="ts"||e=="ps1") m["type"]="Script";
        else if(e=="md"||e=="txt") m["type"]="Prompt";
        else if(e=="yaml"||e=="yml"||e=="toml"||e=="json") m["type"]="Tool";
        else if(l.contains("skill")||l.contains("指令")) m["type"]="Skill";
        else if(l.contains("script")||l.contains("脚本")||l.contains("#!/")) m["type"]="Script";
        else if(l.contains("prompt")||l.contains("提示")) m["type"]="Prompt";
        else if(l.contains("workflow")||l.contains("流程")) m["type"]="Workflow";
        else m["type"]="Script";
    }
    if(!m.contains("name")){ QRegularExpression re("^#\\s+(.+)$",QRegularExpression::MultilineOption); auto mm=re.match(t); m["name"]=mm.hasMatch()?mm.captured(1).trimmed():QFileInfo(fp).completeBaseName(); }
    if(!m.contains("description")){ QString b=c; b.remove(QRegularExpression("^#.*\\n?",QRegularExpression::MultilineOption));
        b.remove(QRegularExpression("^.*---.*\\n?",QRegularExpression::MultilineOption));
        for(auto &l:b.trimmed().split('\n')){ auto s=l.trimmed(); if(!s.isEmpty()&&!s.startsWith('#')&&!s.startsWith("//")&&!s.startsWith("/*")){ m["description"]=s.left(80); break; }}}
    if(!m.contains("version")) m["version"]="1.0";
    m["content"]=c; return m["name"].toString().isEmpty()?QVariantMap():m;
}

QVariantList FileHelper::scanAllDrafts() {
    QVariantList r;
    for(auto &td:QStringList{"skills","scripts","prompts","tools","workflows"}){
        QDir d(draftsPath()+"/"+td);
        for(auto &f:d.entryList(QDir::Files,QDir::Time)){
            if(!f.endsWith(".md")&&!f.endsWith(".txt")&&!f.endsWith(".py")&&!f.endsWith(".sh")&&!f.endsWith(".yaml")&&!f.endsWith(".yml")) continue;
            auto fp=d.absoluteFilePath(f); auto dr=parseFile(fp,td);
            if(dr.isEmpty()||dr["name"].toString().isEmpty()) continue;
            dr["filePath"]=fp; dr["color"]="#58a6ff"; r.append(dr);
        }
    }
    return r;
}
